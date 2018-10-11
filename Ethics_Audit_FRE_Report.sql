with x as 
(SELECT DISTINCT -- patient with order only
  spatient.patientssn,
  spatient.patientname, 
  OrderedItem.EnteredDateTime as OrderDateTime
FROM
  LSV.BISL_R1VX.AR3Y_SPatient_SPatient as Spatient
  LEFT JOIN LSV.BISL_R1VX.AR3Y_CPRSOrder_OrderedItem AS OrderedItem
    ON SPatient.Sta3n = OrderedItem.Sta3n
    AND SPatient.PatientSID = OrderedItem.PatientSID
WHERE
  SPatient.sta3n = '612'
  AND SPatient.PatientName NOT LIKE 'zz%'
  AND OrderedItem.EnteredDateTime > (GETDATE() - 70)
  AND OrderedItem.OrderableItemSID IN
  ('800426248',
  '800426241',
  '800426246',
  '800426239',
  '800426249',
  '800426242',
  '800426244',
  '800426238',
  '800426247',
  '800426237',
  '800426243',
  '800426245',
  '800426236',
  '800426240')
), 
y as 
(SELECT DISTINCT -- patients with tiu
  spatient.patientssn AS patientssn,
  TIUDocument.EntryDateTime AS TIUDateTime,
  TIUDocument.TIUDocumentDefinitionSID
FROM
  LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS Spatient
  LEFT JOIN LSV.BISL_R1VX.AR3Y_TIU_TIUDocument AS TIUDocument
    ON SPatient.Sta3n = TIUDocument.Sta3n
    AND SPatient.PatientSID = TIUDocument.PatientSID
WHERE
  SPatient.sta3n = '612'
  AND SPatient.PatientName NOT LIKE 'zz%'
  AND TIUDocument.EntryDateTime > (GETDATE() - 70)
  AND TIUDocument.TIUDocumentDefinitionSID IN
  ('800120087',
  '800124335',
  '800127052',
  '800127102',
  '800055914')
)
select
  x.patientssn as Patient_SSN,
  x.patientname as Patient_Name,
  CAST(x.OrderDateTime as date) as Order_Date
from
 x
 left join y
   on x.patientssn = y.patientssn
where
  y.TIUDateTime IS NULL
order by
  x.OrderDateTime,
  x.patientssn