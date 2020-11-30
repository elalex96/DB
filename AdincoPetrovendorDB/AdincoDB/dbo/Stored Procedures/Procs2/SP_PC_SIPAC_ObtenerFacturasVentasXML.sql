-- =============================================
-- Author:		Reyna Olvera
-- Create date: 27-06-2018
-- Description:	Extrae facturas archivo xml
-- =============================================
-- 20181105		BAAC	Se modifica para regresar solo una vez cada factura
-- =============================================
-- Author:		Marcos Neri
-- Alter date: 2020-01-21
-- Description:	Agregar JOIN con Nueva Tabla FI_FacturasContratosVolPre
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_SIPAC_ObtenerFacturasVentasXML]
-- [SP_PC_SIPAC_ObtenerFacturasVentasXML] 10011,'2017-03-01'
-- Add the parameters for the stored procedure here
@Contrato  INT, 
@Mes       DATE, 
@IdUsuario INT  = 1
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @ContNumeroProcesado INT;
         -- =============================================
         SET @ContNumeroProcesado =
         (
             SELECT MAX(NumeroProcesado)
             FROM dbo.FI_FacturasContratosVolPre
             WHERE Mes = @Mes
                   AND IdContrato = @Contrato
         );
         --======================================================

         CREATE TABLE #Facturas
         (IdFactura INT, 
          PRIMARY KEY(IdFactura)
         );
         -- =============================================

         IF 0 <
         (
             SELECT COUNT(1)
             FROM dbo.PC_ContratoCampo
             WHERE IdContrato = @Contrato
         )
             BEGIN
                 EXEC SP_PC_SIPAC_Procesar_IdFacturaVenta 
                      @Contrato, 
                      @Mes;
             END;

         -- =============================================
         INSERT INTO #Facturas(IdFactura)
                SELECT IdFactura
                FROM COM_OperacionComercializacion(NOLOCK)
                WHERE IdContrato = @Contrato
                      AND MesReporte = @Mes
                GROUP BY IdFactura;
         -- =============================================

         SELECT FI_F.IdFactura, 
                FIAX.ArchivoXml AS xml, 
                F_VC.ArchivoXML
         FROM #Facturas COM_OC
              JOIN FI_Factura FI_F(NOLOCK) ON COM_OC.IdFactura = FI_F.IdFactura
              JOIN dbo.FI_FacturasContratosVolPre F_VC(NOLOCK) ON F_VC.IdFactura = FI_F.IdFactura
                                                                  AND F_VC.Mes = @Mes
                                                                  AND F_VC.IdContrato = @Contrato
              JOIN FI_ArchivoXml FIAX(NOLOCK) ON FI_F.IdFactura = FIAX.IdFactura
         WHERE F_VC.NumeroProcesado = @ContNumeroProcesado;
     END;