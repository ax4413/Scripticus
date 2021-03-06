/****************************************************/
/* Created by: SQL Server 2008 R2 Profiler          */
/* Date: 18/04/2012  15:29:13         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5 

-- choose db for tracing
declare @DB_ID int = 13


-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share
exec @rc = sp_trace_create @TraceID output, 0, N'c:\temp\trace', @maxfilesize, NULL 
if (@rc != 0) goto error
-- Client side File and Table cannot be scripted


-- please populate the filter table with all sprocs which need to be recorded
DECLARE @Filter TABLE (ObjectID bigint, Name Varchar(255), RowNumber INT identity(1,1))
-- insert into @filter table
INSERT INTO @Filter
	SELECT P.object_id, P.name
	FROM sys.procedures p
	WHERE P.name IN (
		'Address_Fetch', 
		'Allergies_Fetch', 
		'AnsweredQuestionnaires_Fetch', 
		'AppointmentAndEventList_Fetch', 
		'AppointTypeBookableStaffBranch_Fetch', 
		'AppointTypesListAvailable_Fetch', 
		'Appsetting_Fetch', 
		'AvailableManufacturerSuppliers_List', 
		'BranchBrandOverride_Fetch', 
		'BranchListAvailable_Fetch', 
		'BranchManufacturerOverride_Fetch', 
		'BranchPriceOverride_Fetch', 
		'BranchRoomList_BranchID', 
		'BranchSKU_List', 
		'BranchTerminalList_Fetch', 
		'brand_Fetch', 
		'Clinical_LastIssuedRx_Fetch', 
		'ClinicalAdditionalTest_Fetch', 
		'ClinicalAdditionalTest_Insert', 
		'ClinicalAdditionalTestTonomHistory_Fetch', 
		'ClinicalAudit_Insert', 
		'ClinicalCLDispense_Create', 
		'ClinicalCLDispense_Fetch', 
		'ClinicalCLDispense_Insert', 
		'ClinicalCLDispenseOriginalLens_Fetch', 
		'ClinicalCLFittingEdit_Create', 
		'ClinicalCLFittingEdit_Fetch', 
		'ClinicalCLFittingEdit_Insert', 
		'ClinicalCLList_FetchPx', 
		'ClinicalCLProductDetail_Fetch', 
		'ClinicalCLProductDetail_Insert', 
		'ClinicalCLProductDetails_Fetch', 
		'ClinicalCLProductPair_Fetch', 
		'ClinicalCLProductPair_Insert', 
		'ClinicalCLTrialLens_Insert', 
		'ClinicalCLTrialLenses_Fetch', 
		'ClinicalExRx_Fetch', 
		'ClinicalEyeExam_Create', 
		'ClinicalEyeExam_Fetch', 
		'ClinicalEyeExam_Insert', 
		'ClinicalEyeExamStudent_FetchByEyeExam', 
		'ClinicalHistoricalEyeExamList_Fetch', 
		'ClinicalList_Fetch', 
		'ClinicalOphthalmoscopy_Fetch', 
		'ClinicalOphthalmoscopy_Insert', 
		'ClinicalPatientAllergies_Fetch', 
		'ClinicalPatientAllergy_Insert', 
		'ClinicalPatientFamilyMedicalCondition_Insert', 
		'ClinicalPatientFamilyMedicalConditions_Fetch', 
		'ClinicalPatientHobbies_Fetch', 
		'ClinicalPatientHobby_Insert', 
		'ClinicalPatientMedicalCondition_Insert', 
		'ClinicalPatientMedicalConditions_Fetch', 
		'ClinicalPatientMedication_Insert', 
		'ClinicalPatientMedications_Fetch', 
		'ClinicalProductDetail_Insert', 
		'ClinicalProductDetail_Update', 
		'ClinicalPx_Fetch', 
		'ClinicalPx_Fetch_CLDispense', 
		'ClinicalPx_Fetch_CLFit', 
		'ClinicalPx_Fetch_EyeExam', 
		'ClinicalRx_Fetch', 
		'ClinicalRx_Insert', 
		'ClinicalRxDetail_Fetch', 
		'ClinicalRxDetail_Insert', 
		'ClinicalRxIssuedLast_Fetch', 
		'ClinicalSlitLamp_Fetch', 
		'ClinicalSlitLamp_Insert', 
		'ClinicalSolutionProducts_Fetch', 
		'ClinicalSpecLens_Fetch', 
		'ClinicalSpecLensExtras_Fetch', 
		'ClinicalVoucherReason_Insert', 
		'ClinicalVoucherReasons_Fetch', 
		'Colours_Staff_Fetch', 
		'ContactEmailTemplateLite_Fetch', 
		'ContactLensDefinitionLine_List', 
		'ContactTemplateListCategory_Fetch', 
		'DefinitionLineAttribute_List', 
		'DefinitionLineAttributeValue_List', 
		'DiaryAppointment_Create', 
		'DiaryAppointment_CreatePx', 
		'DiaryAppointment_Fetch', 
		'DiaryAppointment_Insert', 
		'DiaryAppointment_Update', 
		'DiaryAppointmentHistory_Insert', 
		'DiaryAvailabilityDaysList_Fetch', 
		'DispensableRxList_Fetch', 
		'GenericTag_List', 
		'GroupDiarySettings_Fetch', 
		'Hobbies_Fetch', 
		'Manufacturer_Fetch', 
		'ManufacturerSupplier_List', 
		'ManufacturerSuppliersForOrderItem_List', 
		'MedicalConditions_Fetch', 
		'Medications_Fetch', 
		'NVList_AppointmentTypes', 
		'NVlist_ClinicalCLTrialFits', 
		'NVList_Staff_Branch', 
		'NVList_StaffBookable_Branch', 
		'OrderSupplierList_Fetch', 
		'Pack_List', 
		'Patient_CurrentTransactions_Fetch', 
		'Patient_Fetch', 
		'PatientAddress_Fetch', 
		'PatientAllergies_Fetch', 
		'PatientCorporates_Fetch', 
		'PatientDeletedGPSurgery_Fetch', 
		'PatientFamilyMedicalConditions_Fetch', 
		'PatientGPInfo_Fetch', 
		'PatientHobbies_Fetch', 
		'PatientLite_Fetch', 
		'PatientMedicalConditions_Fetch', 
		'PatientMedications_Fetch', 
		'PatientNotes_Fetch', 
		'PatientSummary_Fetch', 
		'PatientSummary_FetchByPublicID', 
		'PatientUDFieldNames_Fetch', 
		'PatientUDValuesDeleted_Fetch', 
		'PaymentSchemaList', 
		'PermissionGroupListActive_Fetch', 
		'Product_ProductAttributes', 
		'ProductAttributeValue_List', 
		'ProductContactLens_Fetch', 
		'ProductTagList_Fetch', 
		'ProductTags_Fetch', 
		'ProductType_AttributeList', 
		'PxAdHocData_Fetch', 
		'PxAppointmentCount', 
		'PxCurrentContactLens_Insert', 
		'PxCurrentContactLenses_Fetch', 
		'PxCurrentSolutions_Fetch', 
		'PxOpenTransPreviousDayOrSession_Fetch', 
		'PxOrder_Fetch', 
		'PxOrder_FetchOrderNumber', 
		'PxOrder_Insert', 
		'PxOrder_Update', 
		'PxOrderItem_Insert', 
		'PxOrderItem_Update', 
		'PxOrderItems_Fetch', 
		'PxOrderNotes_Fetch', 
		'PxOrdersByCustomerStatus_Fetch', 
		'PxOrderStatusHistory_Insert', 
		'PxScheme_Update', 
		'PxSchemeItem_Insert', 
		'PxSchemeItems_FetchAll', 
		'PxSchemePostedBalances_List', 
		'PxSchemeProductList_Fetch', 
		'PxSchemes_Fetch', 
		'PxSummaryAppointments_Fetch', 
		'PxSummaryContactLens_Refresh', 
		'PxSummaryDetails_Refresh', 
		'PxSummaryEyeExam_Refresh', 
		'PxSummaryOrders_Refresh', 
		'PXSummaryRecall_Refresh', 
		'PxSummaryTransCount_Refresh', 
		'PxSupplySchedule_Fetch', 
		'PxSupplySchedule_Reset', 
		'PxVoucherReason_Delete', 
		'PxVoucherReason_Insert', 
		'PxVoucherReasons_Fetch', 
		'QuestionnaireListByTextBoxInstance_Fetch', 
		'RecallGroup_Fetch', 
		'RecallGroupListActive_Fetch', 
		'RecallPxGroupPosition_Update', 
		'RecallPxGroupPositions_Fetch', 
		'RecallSteps_Fetch', 
		'ReferringPatient_Fetch', 
		'RxReadOnlyPair_Fetch', 
		'SchemeList_Fetch', 
		'Staff_Fetch', 
		'StaffAddress_Fetch', 
		'StaffAppointTypes_Fetch', 
		'StaffBranches_Fetch', 
		'StaffList_Fetch', 
		'StaffListBookableBranch_Fetch', 
		'StaffPermissionGroups_Fetch', 
		'Supplier_Fetch', 
		'SupplierBranchesRef_Fetch', 
		'SupplierManufacturer_Fetch', 
		'TaskCount_Fetch', 
		'TillDiscountCodes_Fetch', 
		'TillPaymentType_FetchAll', 
		'TillPxTransaction_Insert', 
		'TillPxTransaction_Update', 
		'TillPxTransactionCurrent_Fetch', 
		'TillPxTransactionCurrentTransState_Fetch', 
		'TillSession_FetchCurrent', 
		'TillSessionPayments_Fetch', 
		'TillSetting_Fetch', 
		'TillTransaction_Fetch', 
		'TillTransaction_FetchPublicID', 
		'TillTransactionCardReturnTypes_Fetch', 
		'TillTransactionItem_FetchAll', 
		'TillTransactionItem_Update', 
		'TillTransactionItemClinical_Insert', 
		'TillTransDiscount_FetchAll', 
		'TillTransItemDiscount_FetchAll', 
		'TillTransPayment_FetchAll', 
		'VATScheme_Fetch', 
		'VATSchemeHistory_List')



-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 17, 1, @on
exec sp_trace_setevent @TraceID, 17, 2, @on
exec sp_trace_setevent @TraceID, 17, 14, @on
exec sp_trace_setevent @TraceID, 17, 26, @on
exec sp_trace_setevent @TraceID, 17, 3, @on
exec sp_trace_setevent @TraceID, 17, 35, @on
exec sp_trace_setevent @TraceID, 17, 12, @on
exec sp_trace_setevent @TraceID, 43, 1, @on
exec sp_trace_setevent @TraceID, 43, 26, @on
exec sp_trace_setevent @TraceID, 43, 34, @on
exec sp_trace_setevent @TraceID, 43, 3, @on
exec sp_trace_setevent @TraceID, 43, 35, @on
exec sp_trace_setevent @TraceID, 43, 12, @on
exec sp_trace_setevent @TraceID, 43, 14, @on
exec sp_trace_setevent @TraceID, 43, 22, @on
exec sp_trace_setevent @TraceID, 42, 1, @on
exec sp_trace_setevent @TraceID, 42, 14, @on
exec sp_trace_setevent @TraceID, 42, 22, @on
exec sp_trace_setevent @TraceID, 42, 26, @on
exec sp_trace_setevent @TraceID, 42, 34, @on
exec sp_trace_setevent @TraceID, 42, 3, @on
exec sp_trace_setevent @TraceID, 42, 35, @on
exec sp_trace_setevent @TraceID, 42, 12, @on
exec sp_trace_setevent @TraceID, 44, 1, @on
exec sp_trace_setevent @TraceID, 44, 26, @on
exec sp_trace_setevent @TraceID, 44, 34, @on
exec sp_trace_setevent @TraceID, 44, 3, @on
exec sp_trace_setevent @TraceID, 44, 35, @on
exec sp_trace_setevent @TraceID, 44, 12, @on
exec sp_trace_setevent @TraceID, 44, 14, @on
exec sp_trace_setevent @TraceID, 44, 22, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

set @intfilter = @DB_ID
exec sp_trace_setfilter @TraceID, 3, 0, 0, @intfilter



-- LOOP THE FILTER TABLE CREATING FILTERS FOR EACH SPROC
declare @id int = 0
select @id = MAX(Rownumber) from @filter

declare @sql nvarchar(max)

while @id !=  0
begin

	select @sql = 'exec sp_trace_setfilter ' + cast(@TraceID as varchar(50)) + ', 22, 1, 0, ' + cast(objectId as varchar(50)) from @Filter where RowNumber = @id
	print @sql

set @id = @id -1
end



-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
