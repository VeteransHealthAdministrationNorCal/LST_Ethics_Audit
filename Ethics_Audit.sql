SELECT 
  OI.OrderedItemSID,
  DIMOI.OrderableItemName,
  OI.PatientSID,
  OI.EnteredByStaffSID,
  OI.EnteredDateTime,
  convert(date, OI.EnteredDateTime) as lstDate,
  OI.OrderStartDateTime,
  OI.OrderStartVistaDate,
  OI.OrderStopDateTime

FROM 
  LSV.BISL_R1VX.AR3Y_CPRSOrder_OrderedItem AS OI
  INNER JOIN LSV.DIM.OrderableItem AS DIMOI
    ON OI.OrderableItemSID = DIMOI.OrderableItemSID
    AND OI.Sta3n = DIMOI.Sta3n
  INNER JOIN LSV.BISL_R1VX.AR3Y_SPatient_SPatient as PAT 
    on PAT.PatientSID = OI.PatientSID 
	and OI.Sta3n = PAT.Sta3n

WHERE 
  OI.Sta3n = '612'
  and DIMOI.OrderableItemName like 'LST%'
  AND OI.EnteredDateTime > = cast('2018-04-16' as datetime2(0)) 
GO


SELECT TOP (5000) 
  pat.PatientSSN,
  HF.HealthFactorSID,
  HFT.HealthFactorType,
  HFT.HealthFactorCategory,
  HF.HealthFactorIEN,
  HF.Sta3n,
  HF.HealthFactorTypeSID,
  HF.PatientSID,
  visit.PatientSID as vPatientSID,
  loc.LocationName,
  HF.VisitDateTime,
  HF.VisitVistaErrorDate,
  HF.HealthFactorDateTime,
  convert(date, HEALTHFactorDateTime) as lstDate,
  HF.LevelSeverity,
  HF.EncounterStaffSID,
  HF.VisitSID,
  HF.VerifiedStatus,
  HF.AuditTrail,
  HF.PCEDataSourceSID,
  HF.EditedFlag,
  HF.Comments

FROM
  LSV.BISL_R1VX.AR3Y_HF_HealthFactor AS HF
  INNER JOIN LSV.Dim.HealthFactorType AS HFT
    ON HF.HealthFactorTypeSID = HFT.HealthFactorTypeSID
    AND HF.Sta3n = HFT.Sta3n
  left join LSV.BISL_R1VX.AR3Y_Outpat_Visit as visit 
	on hf.visitSID = visit.visitSID
	and hf.Sta3n = visit.Sta3n	
  inner join LSV.Dim.Location as loc
	on loc.LocationSID  = visit.LocationSID
  INNER JOIN LSV.BISL_R1VX.AR3Y_SPatient_SPatient as PAT 
    on PAT.PatientSID = HF.PatientSID
	and HF.Sta3n = PAT.Sta3n

WHERE
  HF.Sta3n = '612'
  AND HFT.Sta3n=612
  AND HFT.HealthFactorCategory LIKE '%ETHICS-%'
  AND HFT.HealthFactorCategory NOT LIKE '%ETHICS-ADVANCE DIRECTIVE SCR%'
  AND HF.HealthFactorDateTime > = cast('2018-04-16' as  datetime2(0))
  and pat.PatientLastName not like 'zz%'
  --and pat.TestPatientFlag <> 'Y'
ORDER BY
  pat.PatientSSN,
  HFT.HealthFactorCategory
GO


SELECT
  TIUDocumentSID,
  PAT.TestPatientFlag,
  Pat.PatientSSN,
  Pat.PatientFirstName,
  Pat.PatientLastName,
  TIU.EntryDateTime,
  convert(date, TIU.EntryDateTime) as lstDate,
  TIU.VisitSID

FROM
  LSV.BISL_R1VX.AR3Y_TIU_TIUDocument AS TIU
  INNER JOIN LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS PAT
    ON PAT.PatientSID = TIU.PatientSID
    AND PAT.Sta3n = TIU.Sta3n

WHERE
  (TIU.TIUDocumentDefinitionSID = 800120087
  OR TIU.TIUDocumentDefinitionSID = (800124335))
  AND TIU.Sta3n = '612'
  AND TIU.EntryDateTime >=CAST('2018-04-16' as  datetime2(0))
  and PAT.PatientLastName not like '%ZZA-Z%'
GO


SELECT DISTINCT
  SPatient.PatientSSN,
  SPatient.PatientLastName,
  SPatient.PatientFirstName,
  --OrderedItem.EnteredDateTime,
  CAST(OrderedItem.EnteredDateTime AS date) AS EnteredDate,
  --OrderedItem.OrderStartDateTime,
  --OrderedItem.OrderStopDateTime,
  DimOrderedItem.OrderableItemName,
  --HealthFactor.VisitDateTime,
  --HealthFactor.HealthFactorDateTime,
  CAST(HealthFactor.HealthFactorDateTime AS date) AS HealthFactorDate,
  --HealthFactor.LevelSeverity,
  --HealthFactor.VerifiedStatus,
  HealthFactor.AuditTrail,
  --HealthFactor.EditedFlag,
  HealthFactor.Comments,
  --HealthFactorType.HealthFactorType,
  --HealthFactorType.HealthFactorCategory,
  CAST(Visit.VisitDateTime AS date) AS VisitDate,
  TIU.TIUDocumentSID,
  --TIU.EntryDateTime,
  CAST(TIU.EntryDateTime AS date) AS TIUEntryDate
  -- add CAN SCORE 1Y
  
FROM
  LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS SPatient
  
  INNER JOIN LSV.BISL_R1VX.AR3Y_CPRSOrder_OrderedItem AS OrderedItem
    ON SPatient.PatientSID = OrderedItem.PatientSID
       AND SPatient.Sta3n = OrderedItem.Sta3n
  INNER JOIN LSV.Dim.OrderableItem AS DimOrderedItem
    ON OrderedItem.OrderableItemSID = DimOrderedItem.OrderableItemSID
    AND OrderedItem.Sta3n = DimOrderedItem.Sta3n

  INNER JOIN LSV.BISL_R1VX.AR3Y_HF_HealthFactor AS HealthFactor
    ON SPatient.PatientSID = HealthFactor.PatientSID
       AND SPatient.Sta3n = HealthFactor.Sta3n
  INNER JOIN LSV.Dim.HealthFactorType AS HealthFactorType
    ON HealthFactor.HealthFactorTypeSID = HealthFactorType.HealthFactorTypeSID
    AND HealthFactor.Sta3n = HealthFactorType.Sta3n

  INNER JOIN LSV.BISL_R1VX.AR3Y_Outpat_Visit AS Visit
    ON SPatient.PatientSID = Visit.PatientSID
       AND SPatient.Sta3n = Visit.Sta3n
  INNER JOIN LSV.BISL_R1VX.AR3Y_TIU_TIUDocument AS TIU
    ON Visit.VisitSID = TIU.VisitSID
       
WHERE 
  SPatient.Sta3n = '612'
  AND SPatient.PatientLastName NOT LIKE '%ZZ%'
  AND OrderableItemName LIKE 'LST%'
  AND OrderedItem.EnteredDateTime >= CAST('2018-04-16' AS datetime2(0))
  AND HealthFactorType.HealthFactorCategory LIKE '%ETHICS-%'
  AND HealthFactorType.HealthFactorCategory NOT LIKE '%ETHICS-ADVANCE DIRECTIVE SCR%'
  AND HealthFactor.HealthFactorDateTime >= CAST('2018-04-16' AS  datetime2(0))
  AND (
    TIU.TIUDocumentDefinitionSID = 800120087 
    OR TIU.TIUDocumentDefinitionSID = (800124335)
       )
  AND TIU.EntryDateTime >= CAST('2018-04-16' AS  datetime2(0))

ORDER BY
  SPatient.PatientSSN
  --HealthFactorType.HealthFactorCategory

GO


SELECT DISTINCT
  SPatient.PatientSSN,
  SPatient.PatientLastName,
  SPatient.PatientFirstName,
  --OrderedItem.EnteredDateTime,
  CAST(OrderedItem.EnteredDateTime AS date) AS EnteredDate,
  --OrderedItem.OrderStartDateTime,
  --OrderedItem.OrderStopDateTime,
  DimOrderedItem.OrderableItemName,
  --HealthFactor.VisitDateTime,
  --HealthFactor.HealthFactorDateTime,
  CAST(HealthFactor.HealthFactorDateTime AS date) AS HealthFactorDate,
  --HealthFactor.LevelSeverity,
  --HealthFactor.VerifiedStatus,
  HealthFactor.AuditTrail,
  --HealthFactor.EditedFlag,
  HealthFactor.Comments,
  --HealthFactorType.HealthFactorType,
  --HealthFactorType.HealthFactorCategory,
  CAST(Visit.VisitDateTime AS date) AS VisitDate,
  TIU.TIUDocumentSID,
  --TIU.EntryDateTime,
  CAST(TIU.EntryDateTime AS date) AS TIUEntryDate
  -- add CAN SCORE 1Y
  
FROM
  LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS SPatient
  INNER JOIN LSV.BISL_R1VX.AR3Y_Outpat_Visit AS Visit
    ON SPatient.PatientSID = Visit.PatientSID
       AND SPatient.Sta3n = Visit.Sta3n
  
  INNER JOIN LSV.BISL_R1VX.AR3Y_TIU_TIUDocument AS TIU
    ON Visit.VisitSID = TIU.VisitSID
  INNER JOIN LSV.BISL_R1VX.AR3Y_HF_HealthFactor AS HealthFactor
    ON TIU.VisitSID = HealthFactor.VisitSID
  INNER JOIN LSV.Dim.HealthFactorType AS HealthFactorType
    ON HealthFactor.HealthFactorTypeSID = HealthFactorType.HealthFactorTypeSID
    AND HealthFactor.Sta3n = HealthFactorType.Sta3n
  
  INNER JOIN LSV.BISL_R1VX.AR3Y_CPRSOrder_CPRSOrder AS CPRSOrder
    ON Visit.PatientSID = CPRSOrder.PatientSID
    AND Visit.Sta3n = CPRSOrder.Sta3n
  INNER JOIN LSV.BISL_R1VX.AR3Y_CPRSOrder_OrderedItem AS OrderedItem
    ON CPRSOrder.CPRSOrderSID = OrderedItem.CPRSOrderSID
  INNER JOIN LSV.Dim.OrderableItem AS DimOrderedItem
    ON OrderedItem.OrderableItemSID = DimOrderedItem.OrderableItemSID
	       
WHERE 
  SPatient.Sta3n = '612'
  AND SPatient.PatientLastName NOT LIKE '%ZZ%'
  AND OrderableItemName LIKE 'LST%'
  AND OrderedItem.EnteredDateTime >= CAST('2018-04-16' AS datetime2(0))
  AND HealthFactorType.HealthFactorCategory LIKE '%ETHICS-%'
  AND HealthFactorType.HealthFactorCategory NOT LIKE '%ETHICS-ADVANCE DIRECTIVE SCR%'
  AND HealthFactor.HealthFactorDateTime >= CAST('2018-04-16' AS  datetime2(0))
  AND (
    TIU.TIUDocumentDefinitionSID = 800120087 
    OR TIU.TIUDocumentDefinitionSID = (800124335)
       )
  AND TIU.EntryDateTime >= CAST('2018-04-16' AS  datetime2(0))

ORDER BY
  SPatient.PatientSSN
  --HealthFactorType.HealthFactorCategory
GO