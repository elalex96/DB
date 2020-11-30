CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturas]
    @IdContrato INT,
    @PInicial   NVARCHAR(50),
    @PFinal     NVARCHAR(50)
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 08-05-17
-- Description:	
-- =============================================
SET NOCOUNT ON
-- =============================================
    DECLARE
	   @CONTRATISTA    INT,
	   @RazonSocial	VARCHAR(500)

    SELECT @CONTRATISTA = Ca.IdContratista,
	   @RazonSocial    =   CA.RazonSocial
    FROM CO_Contrato Co
        JOIN CO_Contratista Ca ON Co.IdContratista = Ca.IdContratista
    WHERE Co.IdContrato = @IdContrato;

    -- Insert statements for procedure here

    IF @CONTRATISTA = 10000
    BEGIN
        SELECT CAST(F.IdFactura AS NVARCHAR(50)) AS IdFactura,
            Folio,
            Fecha,
            UUID AS MetodoPago,
            SubTotal,
            MontoConIva,
            Moneda,
            archivoXML AS LugarExpedicion,
            Emisor,
            SE.RazonSocial,
            Receptor,
            CA.RazonSocial,
            FechaTimbrado
        FROM FI_Factura F   (NOLOCK)
        JOIN PV_Subcontratista SE	 (NOLOCK)
		  ON F.IdSubcontratista = SE.IdSubcontratista
	   JOIN CO_Contrato C 
		  ON C.IdContrato = @IdContrato
	   JOIN CO_Contratista CA 
		  ON C.IdContratista = CA.IdContratista
        WHERE C.IdContratista = @Contratista
            AND F.Fecha BETWEEN @PInicial AND @PFinal
            AND isnull(F.ProcesadoSIPAC, 'false') = 'false'
            AND RTRIM(ArchivoXML) <> '';
    END
    ELSE
    BEGIN
	   SELECT
		  CAST(F.IdFactura AS NVARCHAR(50)) AS IdFactura,
		  Folio,
		  Fecha,
		  UUID AS MetodoPago,
		  SubTotal,
		  MontoConIva,
		  Moneda,
		  archivoXML AS LugarExpedicion,
		  Emisor,
		  SE.RazonSocial,
		  Receptor,
		  @RazonSocial	   AS  RazonSocial,
		  FechaTimbrado
	   FROM
		   FI_Factura F   (NOLOCK)
	   JOIN
		   PV_Subcontratista SE 
		  ON F.IdSubcontratista = SE.IdSubcontratista
	   --JOIN CO_Contrato C
	   --ON C.IdContrato = F.IdContrato
	   --JOIN
	   --CO_Contratista CA
	   --ON C.IdContratista = CA.IdContratista
	   WHERE F.IdContrato = @IdContrato
		  AND F.Fecha BETWEEN @PInicial AND @PFinal
		  AND isnull(CONVERT(INT,F.ProcesadoSIPAC), 0) = 0
		  AND RTRIM(ArchivoXML) <> ''
    END
END

