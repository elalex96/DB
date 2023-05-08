-- =============================================
-- Author:		Miguel G
-- Create date: 
-- Description:	Reporte de comercializaiones R8 PMI PTI Facturas
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_Reporte8] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SELECT R8.Factura, R8.FechaFactura  , 
PMI.FechaTimbrado , 
r8.Denominación, 
r8.Nombre1, 
r8.CantidadFacturada, 
r8.Energía, 
pmi.Total, 
pmi.Moneda, 
pmi.UUID, 
TCD.TipoCambio,
c.ValorUnitario,
C.Cantidad,
C.Unidad,
case when r8.CantidadFacturada <> C.cantidad then 'Diferencia en Cantidades' else '-' end


 FROM dbo.PC_Comercializacion_V2 R8
join PC_PMI_V2 PMI on PMI.Factura= R8.Referencia1
left join FI_Factura F on F.UUID= pmi.UUID
left join FI_CFDIConcepto C on C.IdFactura = f.IdFactura
left join CO_TipoCambioDiario TCD on F.IdMoneda =TCD.IdMoneda 
and day(F.FechaTimbrado)= day(TCD.Fecha)
and month(F.FechaTimbrado)= month(TCD.Fecha)
and year(F.FechaTimbrado)= year(TCD.Fecha)
WHERE R8.factura LIKE '92%' OR R8.Factura like '93%'  and month (PMI.FechaTimbrado)= 12

union 

SELECT R8.Factura, R8.FechaFactura  , 
PMI.FechaTimbrado , 
r8.Denominación, 
r8.Nombre1, 
r8.CantidadFacturada, 
r8.Energía, 
pmi.Total, 
pmi.Moneda, 
pmi.UUID, 
TCD.Tipocambio ,
c.ValorUnitario,
C.Cantidad,
C.Unidad
,case when r8.CantidadFacturada <> C.cantidad then 'Diferencia en Cantidades' else '-' end


 FROM dbo.PC_Comercializacion_V2 R8
join PC_PTI_V2 PMI on PMI.Factura= R8.Referencia1
left join FI_Factura F on F.UUID= pmi.UUID
left join FI_CFDIConcepto C on C.IdFactura = f.IdFactura
left join CO_TipoCambioDiario TCD on F.IdMoneda =TCD.IdMoneda 
and day(F.FechaTimbrado)= day(TCD.Fecha)
and month(F.FechaTimbrado)= month(TCD.Fecha)
and year(F.FechaTimbrado)= year(TCD.Fecha)
WHERE R8.factura LIKE '92%' OR R8.Factura like '93%'  and month (PMI.FechaTimbrado)= 12
--select * from PC_PMI_V2
END
