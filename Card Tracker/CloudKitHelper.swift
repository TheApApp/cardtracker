//
//  CloudKitHelper.swift
//  Card Tracker
//
//  Created by Michael Rowe on 6/13/21.
//  From Stack Overflow
//

import Foundation
import CloudKit

public class CloudKitHelper {
    private static func determineRetry(error: Error) -> Double? {
        if let ckerror = error as? CKError {
            switch ckerror {
            case CKError.requestRateLimited, CKError.serviceUnavailable, CKError.zoneBusy, CKError.networkFailure:
                let retry = ckerror.retryAfterSeconds ?? 3.0

                return retry
            default:
                return nil
            }
        } else {
            let nserror = error as NSError
            if nserror.domain == NSCocoaErrorDomain {
                if nserror.code == 4097 {
                    print("cloudd is dead")

                    return 6.0
                }
            }

            print("Unexpected error: \(error)")
        }

        return nil
    }

    public static func modifyRecordZonesOperation(
        database: CKDatabase,
        recordZonesToSave: [CKRecordZone]?,
        recordZoneIDsToDelete: [CKRecordZone.ID]?,
        modifyRecordZonesCompletionBlock: @escaping (([CKRecordZone]?, [CKRecordZone.ID]?, Error?) -> Void)) {
        let opperation = CKModifyRecordZonesOperation(
            recordZonesToSave: recordZonesToSave,
            recordZoneIDsToDelete: recordZoneIDsToDelete)
        // swiftlint:disable:next line_length
        opperation.modifyRecordZonesCompletionBlock = { (savedRecordZones: [CKRecordZone]?, deletedRecordZoneIDs: [CKRecordZone.ID]?, error: Error?) -> Void in
            if let error = error {
                if let delay = determineRetry(error: error) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        CloudKitHelper.modifyRecordZonesOperation(
                            database: database,
                            recordZonesToSave: recordZonesToSave,
                            recordZoneIDsToDelete: recordZoneIDsToDelete,
                            modifyRecordZonesCompletionBlock: modifyRecordZonesCompletionBlock)
                    }
                } else {
                    modifyRecordZonesCompletionBlock(savedRecordZones, deletedRecordZoneIDs, error)
                }
            } else {
                modifyRecordZonesCompletionBlock(savedRecordZones, deletedRecordZoneIDs, error)
            }
        }
        database.add(opperation)
    }

    public static func modifyRecords(
        database: CKDatabase,
        records: [CKRecord],
        completion: @escaping (([CKRecord]?, Error?) -> Void)) {
        CloudKitHelper.modifyAndDeleteRecords(
            database: database,
            records: records,
            recordIDs: nil) { (savedRecords, _, error) in
            completion(savedRecords, error)
        }
    }

    public static func deleteRecords(
        database: CKDatabase,
        recordIDs: [CKRecord.ID],
        completion: @escaping (([CKRecord.ID]?, Error?) -> Void)
    ) {
        CloudKitHelper.modifyAndDeleteRecords(
            database: database,
            records: nil,
            recordIDs: recordIDs) { (_, deletedRecords, error) in
            completion(deletedRecords, error)
        }
    }

    public static func modifyAndDeleteRecords(
        database: CKDatabase,
        records: [CKRecord]?,
        recordIDs: [CKRecord.ID]?,
        completion: @escaping (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
        operation.savePolicy = .allKeys
        // swiftlint:disable:next line_length
        operation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) -> Void in
            if let error = error {
                if let delay = determineRetry(error: error) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        CloudKitHelper.modifyAndDeleteRecords(
                            database: database,
                            records: records,
                            recordIDs: recordIDs,
                            completion: completion)
                    }
                } else {
                    completion(savedRecords, deletedRecordIDs, error)
                }
            } else {
                completion(savedRecords, deletedRecordIDs, error)
            }
        }
        database.add(operation)
    }
}
