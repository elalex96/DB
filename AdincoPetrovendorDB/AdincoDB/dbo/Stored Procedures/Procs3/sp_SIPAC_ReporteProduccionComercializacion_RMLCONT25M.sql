CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteProduccionComercializacion_RMLCONT25M] 
@Contrato INT,
@Mes      DATETIME
AS
     BEGIN
         -- =============================================
	    -- Author:		Miguel Gomez
	    -- Create date:	2017-03-18
	    -- Description:	Reporte de ProdCom - Operaciones Comercialización. 
	    -- =============================================
         SET NOCOUNT ON;
         -- =============================================

         SELECT LTRIM(RTRIM(CA.IDSIPAC)) AS [RF_00],
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],
                LTRIM(RTRIM(C.NumeroContrato)) AS [RF01_01],
                FORMAT(MONTH(vol.mesreporte), '0#') AS [RMLCT25_00],
                YEAR(vol.mesreporte) AS [RMLCT25_01],
                Vol.VolumenPetroleoPuntoMedicion AS [RMLCT25_02],
                vol.GradosAPI AS [RMLCT25_03],
                vol.ContenidoAzufre AS [RMLCT25_04],
                vol.VolumenPetroleoAutoconsumo AS [RMLCT25_05],
                vol.MetanoC1 AS [RMLCT25_06],
                vol.EtanoC2 AS [RMLCT25_07],
                vol.PropanoC3 AS [RMLCT25_08],
                vol.ButanoC4 AS [RMLCT25_09],
                vol.MetanoC1Autoconsumo AS [RMLCT25_10],
                vol.EtanoC2Autoconsumo AS [RMLCT25_11],
                vol.PropanoC3Autoconsumo AS [RMLCT25_12],
                vol.ButanoC4Autoconsumo AS [RMLCT25_13],
                vol.VolumenCondensadoPuntoMedicion AS [RMLCT25_14],
                vol.VolumenCondensadoAutoconsumo AS [RMLCT25_15]
         FROM CO_Contrato C
              JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
              JOIN CO_AnioContractual AC ON C.IdContrato = AC.IdContrato
              JOIN PR_VolumenMensualProduccionPetroleo Vol ON Vol.IdContrato = C.IdContrato
                                                              AND vol.MesReporte = @Mes
         WHERE C.IdContrato = @Contrato;
     END;