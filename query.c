#include "dhun.h"

void notificationCallback(CFNotificationCenterRef  center,
                          void                    *observer,
                          CFStringRef              name,
                          const void              *object,
                          CFDictionaryRef          userInfo)
{
  //CFDictionaryRef attributes;
  //CFArrayRef      attributeNames;
  CFTypeRef         attrValue = NULL;
  CFIndex         idx, count;
  MDItemRef       itemRef = NULL;
  MDQueryRef      queryRef = (MDQueryRef)object;
  CFStringRef      attrName = NULL;
  CFStringEncoding  encoding = CFStringGetSystemEncoding();
  
  if (CFStringCompare(name, kMDQueryDidFinishNotification, 0)
      == kCFCompareEqualTo) { // gathered results
    // disable updates, process results, and reenable updates
    MDQueryDisableUpdates(queryRef);
    count = MDQueryGetResultCount(queryRef);
    if (count > 0) {
      for (idx = 0; idx < count; idx++) {
        itemRef = (MDItemRef)MDQueryGetResultAtIndex(queryRef, idx);
        //attributeNames = MDItemCopyAttributeNames(itemRef);
        //attributes = MDItemCopyAttributes(itemRef, attributeNames);
        attrName = CFStringCreateWithCString(kCFAllocatorDefault,
                                             "kMDItemPath", encoding);
        attrValue = MDItemCopyAttribute(itemRef, attrName);
        CFShow(attrValue);
        //CFRelease(attributes);
        //CFRelease(attributeNames);
      }
      printf("%ld results total\n", count);
    }
    MDQueryEnableUpdates(queryRef);
  } else if (CFStringCompare(name, kMDQueryDidUpdateNotification, 0)
             == kCFCompareEqualTo) { // live update
    CFShow(name), CFShow(object), CFShow(userInfo);
  }
  // ignore kMDQueryProgressNotification
}

int main(int argc, char *argv[])
{
  int                     i;
  CFStringRef             rawQuery = NULL;
  MDQueryRef              queryRef;
  Boolean                 result;
  CFNotificationCenterRef localCenter;
  MDQueryBatchingParams   batchingParams;
  char* query;
  asprintf(&query,QUERY_TEMPLATE,argv[1]);
  printf("Querying for %s\n", query);
  rawQuery = CFStringCreateWithCString(kCFAllocatorDefault, 
                                       query,
                                       CFStringGetSystemEncoding());

  queryRef = MDQueryCreate(kCFAllocatorDefault, rawQuery, NULL, NULL);
  if (queryRef == NULL)
    goto out;

  if (!(localCenter = CFNotificationCenterGetLocalCenter())) {
    fprintf(stderr, "failed to access local notification center\n");
    goto out;
  }

  CFNotificationCenterAddObserver(localCenter,          // process-local center
                                  NULL,                 // observer
                                  notificationCallback, // to process query finish/update notifications
                                  NULL,                 // observe all notifications
                                  (void *)queryRef,     // observe notifications for this object
                                  CFNotificationSuspensionBehaviorDeliverImmediately);

  // maximum number of results that can accumulate and the maximum number
  // of milliseconds that can pass before various notifications are sent
  batchingParams.first_max_num    = 1000; // first progress notification
  batchingParams.first_max_ms     = 1000;
  batchingParams.progress_max_num = 1000; // additional progress notifications
  batchingParams.progress_max_ms  = 1000;
  batchingParams.update_max_num   = 1;    // update notification
  batchingParams.update_max_ms    = 1000;
  MDQuerySetBatchingParameters(queryRef, batchingParams);

  // go execute the query
  MDQueryExecute(queryRef, kMDQuerySynchronous);
 
 out:
  CFRelease(rawQuery);
  if (queryRef)
    CFRelease(queryRef);

  free(query);
  return 0;
}
