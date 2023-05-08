CREATE PROCEDURE [dbo].[sp_PC_SIPAC_Procesar_IdFacturaVentaNuevo] @Contrato INT,
                                                            @Mes      DATE
AS
     BEGIN
-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description: 
-- =============================================
         SET NOCOUNT ON;
         CREATE TABLE #FI_Factura
         (IdFactura  INT,
          IdContrato INT,
          SIPAC      INT
         );
         INSERT INTO #FI_Factura
                SELECT F.IdFactura,
                       OC.IdContrato,
                       ROW_NUMBER() OVER(ORDER BY F.Fecha) AS SIPAC--,
                                                 -- F.IdSubcontratista) AS SIPAC
                FROM FI_Factura f(NOLOCK)
                     JOIN COM_OperacionComercializacion OC(NOLOCK) ON OC.idfactura = f.idfactura
                     JOIN co_contrato c(NOLOCK) ON OC.idcontrato = c.idcontrato
                --WHERE C.IdContrato = @Contrato
			 WHERE OC.IdContrato = @Contrato
                    --  AND DATEFROMPARTS(YEAR(f.Fecha), MONTH(f.Fecha), 1) = @Mes
				   --AND DATEFROMPARTS(YEAR(OC.FechaTransaccion), MONTH(OC.FechaTransaccion), 1) = @Mes
                GROUP BY F.IdFactura,
                         OC.IdContrato,
                         F.Fecha;--,
                         --F.IdSubcontratista;
         UPDATE dbo.FI_Factura
           SET
               IdDocFacturacionSIPAC = 'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6),
               ArchivoXML = 'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml'


	   --ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
	   --Adecuacion Reporte Sampayo
	   --ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
    --     UPDATE dbo.FI_Factura
    --       SET
    --           IdDocFacturacionSIPAC = 'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes)+1)))+LTRIM(MONTH(@Mes)+1)+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6),
    --           ArchivoXML = 'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes)+1)))+LTRIM(MONTH(@Mes)+1)+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FIT.SIPAC AS VARCHAR(6)), 6)+'.xml'
	   ----ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
	 
	 
	    FROM FI_Factura FI
              JOIN #FI_Factura FIT ON FI.IdFactura = FIT.IdFactura;
     END;
