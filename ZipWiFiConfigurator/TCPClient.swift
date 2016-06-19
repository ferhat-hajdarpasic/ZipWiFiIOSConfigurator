//
//  TCPClient.swift
//  ZipWiFiConfigurator
//
//  Created by Ferhat Hajdarpasic on 19/06/2016.
//  Copyright © 2016 Ferhat Hajdarpasic. All rights reserved.
//

import Foundation

public class YSocket{
    var addr:String
    var port:Int
    var fd:Int32?
    init(){
        self.addr=""
        self.port=0
    }
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }
}

@_silgen_name("ytcpsocket_connect") func c_ytcpsocket_connect(host:UnsafePointer<Int8>,port:Int32,timeout:Int32) -> Int32
@_silgen_name("ytcpsocket_close") func c_ytcpsocket_close(fd:Int32) -> Int32
@_silgen_name("ytcpsocket_send") func c_ytcpsocket_send(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@_silgen_name("ytcpsocket_pull") func c_ytcpsocket_pull(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,timeout:Int32) -> Int32
@_silgen_name("ytcpsocket_listen") func c_ytcpsocket_listen(addr:UnsafePointer<Int8>,port:Int32)->Int32
@_silgen_name("ytcpsocket_accept") func c_ytcpsocket_accept(onsocketfd:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32

public class TCPClient:YSocket{
    /*
     * connect to server
     * return success or fail with message
     */
    public func connect(timeout t:Int)->(Bool,String){
        let rs:Int32=c_ytcpsocket_connect(self.addr, port: Int32(self.port), timeout: Int32(t))
        if rs>0{
            self.fd=rs
            return (true,"connect success")
        }else{
            switch rs{
            case -1:
                return (false,"qeury server fail")
            case -2:
                return (false,"connection closed")
            case -3:
                return (false,"connect timeout")
            default:
                return (false,"unknow err.")
            }
        }
    }
    /*
     * close socket
     * return success or fail with message
     */
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            c_ytcpsocket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * send data
     * return success or fail with message
     */
    public func send(data d:[UInt8])->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: d, len: Int32(d.count))
            if Int(sendsize)==d.count{
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * send string
     * return success or fail with message
     */
    public func send(str s:String)->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: s, len: Int32(strlen(s)))
            if sendsize==Int32(strlen(s)){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     *
     * send nsdata
     */
    public func send(data d:NSData)->(Bool,String){
        if let fd:Int32=self.fd{
            var buff:[UInt8] = [UInt8](count:d.length,repeatedValue:0x0)
            d.getBytes(&buff, length: d.length)
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: buff, len: Int32(d.length))
            if sendsize==Int32(d.length){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * read data with expect length
     * return success or fail with message
     */
    public func read(expectlen:Int, timeout:Int = -1)->[UInt8]?{
        if let fd:Int32 = self.fd{
            var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
            let readLen:Int32=c_ytcpsocket_pull(fd, buff: &buff, len: Int32(expectlen), timeout: Int32(timeout))
            if readLen<=0{
                return nil
            }
            let rs=buff[0...Int(readLen-1)]
            let data:[UInt8] = Array(rs)
            return data
        }
        return nil
    }}