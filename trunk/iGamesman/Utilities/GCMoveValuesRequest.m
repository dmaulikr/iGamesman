//
//  GCMoveValuesRequest.m
//  iGamesman
//
//  Created by Kevin Jorgensen on 2/8/12.
//  Copyright (c) 2012 GamesCrafters. All rights reserved.
//

#import "GCMoveValuesRequest.h"

@interface GCMoveValuesRequest ()

- (id) initWithBaseURL: (NSURL *) baseURL parameterString: (NSString *) params;

- (void) setDelegate: (id<GCMoveValuesRequestDelegate>) delegate;

- (void) getMoveValuesForPosition: (NSString *) boardString;

@end



@implementation GCMoveValuesRequest

#pragma mark - Factory method

+ (id) requestWithBaseURL: (NSURL *) baseURL
          parameterString: (NSString *) params
              forPosition: (NSString *) boardString
                 delegate: (id<GCMoveValuesRequestDelegate>) delegate
{
    GCMoveValuesRequest *request = [[GCMoveValuesRequest alloc] initWithBaseURL: baseURL parameterString: params];
    [request setDelegate: delegate];
    
    [request getMoveValuesForPosition: boardString];
    
    return [request autorelease];
}


#pragma mark - Memory lifecycle

- (id) initWithBaseURL: (NSURL *) url parameterString: (NSString *) params
{
    self = [super init];
    
    if (self)
    {
        _baseURL = [url retain];
        _parameterString = [params retain];
    }
    
    return self;
}


- (void) dealloc
{
    [_baseURL release];
    [_parameterString release];
    
    [super dealloc];
}


#pragma mark -

- (void) setDelegate: (id<GCMoveValuesRequestDelegate>) delegate
{
    _delegate = delegate;
}


- (void) getMoveValuesForPosition: (NSString *) boardString
{
    NSString *methodString = [NSString stringWithFormat: @"getNextMoveValues;%@board=%@", _parameterString, boardString];
    NSURL *positionValueURL = [NSURL URLWithString: methodString relativeToURL: _baseURL];
    
    _resultData = [[NSMutableData alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: positionValueURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
    
    if (connection)
    {
        [_delegate moveValuesRequestReachedServer: self];
    }
}


#pragma mark - NSURLConnection delegate

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response
{
    [_resultData setData: nil];
    
    if ([response isKindOfClass: [NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if ([httpResponse statusCode] == 200)
        {
            [_delegate moveValuesRequestDidReceiveResponse: self];
        }
        else
        {
            [_delegate moveValuesRequest: self didFailWithError: [NSError errorWithDomain: @"Server Error" code: 100 userInfo: nil]];
        }
    }
}


- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
    [_resultData appendData: data];
}


- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
    [_resultData release];
    
    [_delegate moveValuesRequest: self didFailWithError: error];
}


- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{    
    NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData: _resultData options: 0 error: nil];
    
    [_resultData release];
    
    
    if ([[resultObject objectForKey: @"status"] isEqualToString: @"ok"])
    {
        [_delegate moveValuesRequestDidReceiveStatusOK: self];
    }
    else if ([[resultObject objectForKey: @"status"] isEqualToString: @"error"])
    {
        [_delegate moveValuesRequest: self didFailWithError: [NSError errorWithDomain: @"Server reported error" code: 200 userInfo: nil]];
        return;
    }
    
    NSArray *response = [resultObject objectForKey: @"response"];
    
    if (response)
    {
        NSMutableArray *moves   = [[NSMutableArray alloc] initWithCapacity: [response count]];
        NSMutableArray *values  = [[NSMutableArray alloc] initWithCapacity: [response count]];
        NSMutableArray *remotes = [[NSMutableArray alloc] initWithCapacity: [response count]];
        
        NSArray *objs = [NSArray arrayWithObjects: GCGameValueWin, GCGameValueLose, GCGameValueTie, GCGameValueDraw, nil];
        NSArray *keys = [NSArray arrayWithObjects: @"win", @"lose", @"tie", @"draw", nil];
        NSDictionary *valueMap = [NSDictionary dictionaryWithObjects: objs forKeys: keys];
        
        for (NSDictionary *entry in response)
        {
            [moves addObject: [entry objectForKey: @"move"]];
            [remotes addObject: [NSNumber numberWithInteger: [[entry objectForKey: @"remoteness"] integerValue]]];
            
            GCGameValue *value = [valueMap objectForKey: [entry objectForKey: @"value"]];
            if (!value)
                value = GCGameValueUnknown;
            [values addObject: value];
        }
        
        [_delegate moveValuesRequest: self receivedValues: values remotenesses: remotes forMoves: moves];
        
        [moves release];
        [values release];
        [remotes release];
    }
}

@end
