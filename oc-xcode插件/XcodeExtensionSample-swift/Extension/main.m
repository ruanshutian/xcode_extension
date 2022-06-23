//
//  main.m
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "XcodeExtensionSampleHelper.h"
#import "XcodeExtensionSampleHelperProtocol.h"
//#import "XcodeExtensionSampleHelpers.swift"
//#import "XC"
//#import "Extension-Bridging-Header.h"


//@objc class XcodeExtensionSampleHelper: NSObject, XcodeExtensionSampleHelperProtocol {
//    func write(text: String, to directory: String, reply: @escaping HelperResultHandler) {
//
//        try? text.write(
//            toFile: directory + "/outputFile",
//            atomically: true, encoding: .utf8
//        )
//
//        reply(0)
//    }
//}
@interface XcodeExtensionSampleHelper : NSObject <XcodeExtensionSampleHelperProtocol>

@end

@implementation XcodeExtensionSampleHelper
- (void)writeText:(NSString * _Nonnull)text to:(NSString * _Nonnull)directory reply:(HelperResultHandler _Nonnull)reply {
    [text writeToFile:[directory stringByAppendingString:@"/outputFile"] atomically:YES encoding:typeUTF8Text error:NO];
    NSLog(@"directory = %@",directory);
//    [text writ]
    reply(0);
}

@end


@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XcodeExtensionSampleHelperProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    XcodeExtensionSampleHelper *exportedObject = [XcodeExtensionSampleHelper new];
    newConnection.exportedObject = exportedObject;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char *argv[])
{
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    return 0;
}
