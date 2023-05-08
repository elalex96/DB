CREATE PROCEDURE AM_RutaDropbox @IdFactura int
AS 
BEGIN
declare @Ruta nvarchar(max) = '\00 Para PEMEX\GASTOS ELEGIBLES\2 INFORMES DE GE',
@Informe nvarchar(150),
@Pat nvarchar(150),
@RazonSocial nvarchar(max),
@Serie nvarchar(max)



SELECT @Informe = CONCAT(YEAR(Fecha), '-' , 
CONCAT (
RIGHT('00' + CONVERT(varchar(2), MONTH(fecha)), 2), ' INFORME GE')), 
@pat =  CONCAT('PAT', ' ',YEAR(Fecha)), 
@RazonSocial = PV_Subcontratista.RazonSocial,@Serie = CONCAT(Serie, ' ', Folio)
FROM FI_Factura 
LEFT JOIN PV_Subcontratista ON PV_Subcontratista.IdSubcontratista = FI_Factura.IdSubcontratista
WHERE IdFactura = @IdFactura

select CONCAT(ISNULL(@Ruta, 'Null'),'\', ISNULL(@Informe, 'Null'),'\', '01 Soportes','\', ISNULL(@Pat,'Null'), '\' , ISNULL(@RazonSocial, 'Null'),'\',  ISNULL(@Serie, 'Null')) as Ruta

END