-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CIEP_ProcesaComprobante 
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@IdActividad   INT,
@Anio          INT,
@Mes           INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         CREATE TABLE #FI_Factura
         ([IdFactura]  [INT],
          [IdContrato] [INT],
          [SIPAC]      [INT]
         );
         INSERT INTO #FI_Factura
                SELECT F.IdFactura,
                       F.IdContrato,
                       ROW_NUMBER() OVER(ORDER BY F.Fecha,
                                                  F.IdSubcontratista) AS SIPAC
                FROM LukoilOficial LO
                     JOIN FI_Factura F ON LO.IdFactura = F.IdFactura
                     JOIN CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = LO.IdPrograma
                WHERE LO.MesCertificado IS NOT NULL
                      AND LPM.IdPresupuesto = @IdPresupuesto
                      AND LPM.IdActividad = @IdActividad
                      AND YEAR(LO.MesInformeFecha) = @Anio
                      AND MONTH(LO.MesInformeFecha) = @Mes
                GROUP BY F.IdFactura,
                         IdContrato,
                         F.Fecha,
                         F.IdSubcontratista;

				     UPDATE dbo.FI_Factura
           SET

       
                IdDocFacturacionSIPAC = CONCAT('PA-', RIGHT('00'+CAST(MONTH(LO.MesInformeFecha) AS VARCHAR(2)), 2), YEAR(LO.MesInformeFecha) - 2000, '-', @IdActividad, '-', FIT.SIPAC, '.PDF')
         FROM FI_Factura FI
              JOIN #FI_Factura FIT ON FI.IdFactura = FIT.IdFactura
              JOIN LukoilOficial LO ON FI.IdFactura = LO.IdFactura
         --GROUP BY Fi.idfactura,
         --         MONTH(LO.MesInformeFecha),
         --         YEAR(LO.MesInformeFecha),
         --         FIT.SIPAC;
    -- Insert statements for procedure here

     END;
