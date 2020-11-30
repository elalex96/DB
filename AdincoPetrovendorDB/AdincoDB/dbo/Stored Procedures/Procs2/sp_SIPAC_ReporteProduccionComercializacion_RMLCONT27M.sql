CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteProduccionComercializacion_RMLCONT27M] 
@Contrato INT,
@Mes      DATETIME
AS
     BEGIN
         -- =============================================
	    -- Author:		Miguel Gomez
	    -- Create date:	2017-03-18
	    -- Description:	Reporte de ProdCom - Operaciones Comercialización. Plantilla--RC_CONT_01_M
	    -- =============================================
         SET NOCOUNT ON;
         -- =============================================

         SELECT LTRIM(RTRIM(CA.IDSIPAC)) AS [RF_00],
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],
                LTRIM(RTRIM(C.NumeroContrato)) AS [RF01_01],
                COM.FechaTransaccion AS [RMLCT27_00],
                ROW_NUMBER() OVER(ORDER BY COM.FechaTransaccion,
                                           COM.IdTipoHidrocarburo ASC) AS [RMLCT27_01],
                TH.TipoHidrocarburo AS [RMLCT27_02],
                COM.VolumenVendido AS [RMLCT27_03],
                COM.PrecioVentaUnitario AS [RMLCT27_04],
                COM.CostoUnitarioComercializacion AS [RMLCT27_05],
                COM.PrecioPuntoMedicion AS [RMLCT27_06],
                UPPER(F.UUID) AS [RMLCT27_07],
                F.IdentificadorSIPAC AS [RMLCT27_08],
                F.NombreXML AS [RMLCT27_09],
                COM.NumeroFolioPedimento AS [RMLCT27_10],
                COM.EPT AS [RMLCT27_11],
                COM.OperacionBajoReglasMercado AS [RMLCT27_12],
                COm.ClasificacionDocumentoSoporte AS [RMLCT27_13],
                '' AS [RC01_15]
         FROM CO_Contrato C
              JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
              JOIN CO_AnioContractual AC ON C.IdContrato = AC.IdContrato
              JOIN COM_OperacionComercializacion COM ON COM.IdContrato = C.IdContrato
                                                        AND com.MesReporte = @Mes
              JOIN CO_TipoHidrocarburo TH ON TH.IdTipoHidrocarburo = COM.IdTipoHidrocarburo
              LEFT JOIN FI_Factura F ON F.IdFactura = COM.IdFactura
         WHERE C.IdContrato = @Contrato;
     END;