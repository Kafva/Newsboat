#import <Foundation/Foundation.h>


int main (int argc, char * argv[])
{
	@autoreleasepool 
	{
		NSString* str1=@"wow1";
		NSString* str2=@"wow2";

		// A block can be assigned to a variable and executed like any other function
		// The righthand side specifies the parameters after ^
		// The type for the block pointer  (^printMessage) reflects the return value from the block
		NSString* (^printMessage)(NSString*, NSString*) = ^(NSString* str1, NSString* str2) { NSLog (@"%@, %@", str1, str2); return @"return value"; } ;
		NSString* str = printMessage (str1,str2);
		NSLog(str);
	}

	return 0;
} 

