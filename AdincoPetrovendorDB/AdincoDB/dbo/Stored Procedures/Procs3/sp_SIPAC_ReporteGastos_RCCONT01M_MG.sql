CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteGastos_RCCONT01M_MG] 
-- Add the parameters for the stored procedure here

AS
         BEGIN
         -- =============================================
         -- Author:		Miguel Gomez
         -- Create date:	2017-03-18
         -- Description:	Reporte de CGI - Registro de costos. Plantilla
         --			RC_CONT_01_M
         -- =============================================
             SET NOCOUNT ON;
		   
/**/
/**/

             SELECT Nombre, [RF_00],
                    [RI_00],
                    [RC01_00],
                    [RC01_01],
                    ROW_NUMBER() OVER(ORDER BY [RC01_04] ASC) AS [RC01_02],
                    [RC01_03],
                    [RC01_04],
                    [RC01_05],
					NombreServicio
                    [RC01_06],
                    [RC01_07],
                    [RC01_08],
                    [RC01_09],
                    [RC01_10],
                    [RC01_11],
                    [RC01_12],
                    [RC01_13],
                    [RC01_14],
                    [RC01_15]
             FROM
(
    SELECT 
    --F.IdFactura,
	p.Nombre,
    LTRIM(RTRIM(con.IDSIPAC)) AS [RF_00],
    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],
    CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1)), 103) AS [RC01_00],
    F.IdDocFacturacionSIPAC AS [RC01_01],
    NULL AS [RC01_02], -- ROW_NUMBER() OVER(ORDER BY SP.[id_Sub-actividad] ASC)
    LTRIM(RTRIM(APCNH.DescripcionActividadPetrolera)) AS [RC01_03],
    LTRIM(RTRIM(SP.SubactividadPetrolera)) AS [RC01_04],
    LTRIM(RTRIM(TP.TareaPetrolera)) AS [RC01_05],
	s.nombreservicio,
    LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) AS [RC01_06],
    LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) AS [RC01_07],
    LTRIM(RTRIM(I.NombreInstalacion)) AS [RC01_08],
    CC.Nivel3 AS [RC01_09],
    CC.Descripcion AS [RC01_10],
    R.poliza AS [RC01_11],
    R.Comentarios AS [RC01_12],
    CASE
        WHEN ISNULL(R.MontoRegistro, 0) <> 0
        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
        ELSE 0
    END AS [RC01_13],
    CASE
        WHEN isnull(CONVERT(INT, CC.Operacion), 3) = 1
        THEN 1
        WHEN isnull(CONVERT(INT, CC.Operacion), 3) = 0
        THEN 2
        ELSE 2
    END AS [RC01_14],
    P.IdPresupuestoCNH AS [RC01_15]
    FROM fi_transfer tr
         LEFT JOIN fi_transferfactura tf ON tr.idtransferencia = tf.idtransfer
         LEFT JOIN fi_factura f ON tf.idfactura = f.idfactura
         LEFT JOIN co_registro r ON r.idfactura = f.idfactura
         LEFT JOIN co_lineapresupuestomes lpm ON r.idprograma = lpm.idlineapresupuestomes
         LEFT JOIN co_presupuesto p ON p.idpresupuesto = lpm.idpresupuesto
         LEFT JOIN Co_anioContractual AC ON AC.idaniocontractual = p.idaniocontractual
         LEFT JOIN co_contrato c ON ac.idcontrato = c.idcontrato
         LEFT JOIN co_contratista con ON c.idcontratista = con.idcontratista
         LEFT JOIN CO_ActividadPetroleraCNH APCNH ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
         LEFT JOIN CO_SubactividadPetrolera SP ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
         LEFT JOIN CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
         LEFT JOIN CO_Instalacion I ON R.IdInstalacion = I.IdInstalacion
         LEFT JOIN PD_Campo CPO ON I.IdCampo = CPO.IdCampo
         LEFT JOIN CO_Yacimiento Y ON CPO.IdYacimiento = Y.IdYacimiento
         LEFT JOIN CO_CatalogoCuentaSH CC ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
         LEFT JOIN PV_TipoMoneda TM ON F.IdMoneda = TM.IdMoneda
		 left join co_servicio s on s.idservicio=lpm.idservicio 
         LEFT JOIN CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
                                              AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                              AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                              AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
    WHERE C.IdContrato in (10001,10002,10003)
          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) < '20170101'
          AND R.IdEstado = 10004
          AND R.CvTipoDocFacturacion = 1
          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
          --AND p.idpresupuesto = @IdPresupuesto
          --AND CC.IdVersion = 10001
    GROUP BY p.nombre, LTRIM(RTRIM(con.IDSIPAC)),
             LTRIM(RTRIM(C.IDRegFiducidiario)),
             CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1)), 103),
             F.IdDocFacturacionSIPAC,
             LTRIM(RTRIM(APCNH.DescripcionActividadPetrolera)),
             SP.SubactividadPetrolera,
             LTRIM(RTRIM(TP.TareaPetrolera)),
			 s.NombreServicio,
             LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))),
             LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))),
             LTRIM(RTRIM(I.NombreInstalacion)),
             CC.Nivel3,
             CC.Descripcion,
             R.poliza,
             R.Comentarios,
             CASE
                 WHEN ISNULL(R.MontoRegistro, 0) <> 0
                 THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                 ELSE 0
             END,
             CASE
                 WHEN isnull(CONVERT(INT, CC.Operacion), 3) = 1
                 THEN 1
                 WHEN isnull(CONVERT(INT, CC.Operacion), 3) = 0
                 THEN 2
                 ELSE 2
             END,
             P.IdPresupuestoCNH
    --
    UNION
    --
    SELECT 
    --PC.IdPedimentoComprobante,
	p.Nombre,
    LTRIM(RTRIM(con.IDSIPAC)) AS [RF_00],
    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],
    CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1)), 103) AS [RC01_00],
    PC.IdDocFacturacionSIPAC AS [RC01_01],
    NULL AS [RC01_02], -- ROW_NUMBER() OVER(ORDER BY SP.[id_Sub-actividad] ASC)
    LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC01_03],
    LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC01_04],
    LTRIM(RTRIM(TP.id_Tarea)) AS [RC01_05],
	s.nombreservicio,
    LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) AS [RC01_06],
    LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) AS [RC01_07],
    LTRIM(RTRIM(I.NombreInstalacion)) AS [RC01_08],
    CC.Nivel3 AS [RC01_09],
    CC.Descripcion AS [RC01_10],
    TR.NumeroPolizaContable AS [RC01_11],
    TR.Concepto AS [RC01_12],
    CASE
        WHEN ISNULL(R.MontoRegistro, 0) <> 0
        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
        ELSE 0
    END AS [RC01_13],
    CASE
        WHEN CAPEX = 1
        THEN 2
        ELSE 1
    END AS [RC01_14],
    P.IdPresupuestoCNH AS [RC01_15]
    FROM fi_transfer tr
         LEFT JOIN FI_transferfactura TF ON TF.IdTransfer = TR.IdTransferencia
         LEFT JOIN FI_PedimentoComprobante PC ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
         LEFT JOIN co_registro r ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
         LEFT JOIN co_lineapresupuestomes lpm ON r.idprograma = lpm.idlineapresupuestomes
         LEFT JOIN co_presupuesto p ON p.idpresupuesto = lpm.idpresupuesto
         LEFT JOIN Co_anioContractual AC ON AC.idaniocontractual = p.idaniocontractual
         LEFT JOIN co_contrato c ON ac.idcontrato = c.idcontrato
         LEFT JOIN co_contratista con ON c.idcontratista = con.idcontratista
         LEFT JOIN CO_ActividadPetroleraCNH APCNH ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
         LEFT JOIN CO_SubactividadPetrolera SP ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
         LEFT JOIN CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
         LEFT JOIN CO_Instalacion I ON R.IdInstalacion = I.IdInstalacion
         LEFT JOIN PD_Campo CPO ON I.IdCampo = CPO.IdCampo
         LEFT JOIN CO_Yacimiento Y ON CPO.IdYacimiento = Y.IdYacimiento
         LEFT JOIN CO_CatalogoCuentaSH CC ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
         LEFT JOIN PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda

		 left join co_servicio s on s.idservicio = lpm.idservicio
         LEFT JOIN CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
                                              AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                              AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                              AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
    WHERE C.IdContrato in (10001,10002,10003)
          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) < '20170101'
          AND R.IdEstado = 10004
          AND R.CvTipoDocFacturacion IN(2, 3)
         AND ISNULL(PC.ProcesadoSIPAC, 0) = 0
         --AND p.idpresupuesto = @IdPresupuesto
         --AND CC.IdVersion = 10001
    GROUP BY p.nombre,PC.IdPedimentoComprobante,
             con.IDSIPAC,
             C.IDRegFiducidiario,
             R.MesPresentacion,
             APCNH.id_Actividad,
             SP.[id_Sub-actividad],
             TP.id_Tarea,
			 s.NombreServicio,
             CPO.NombreCampo,
             Y.NombreYacimiento,
             I.NombreInstalacion,
             CASE
                 WHEN ISNULL(R.MontoRegistro, 0) <> 0
                 THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                 ELSE 0
             END,
             CASE
                 WHEN CAPEX = 1
                 THEN 2
                 ELSE 1
             END,
             PC.IdDocFacturacionSIPAC,
             CC.Nivel3,
             CC.Descripcion,
             TR.NumeroPolizaContable,
             TR.Concepto,
             P.IdPresupuestoCNH
) C;

         --select * from sys.objects where name like '%cuenta%' and type = 'f'
         --EXEC sp_SIPAC_ReporteGastos_RCCONT01M 10003,'2016-07-01',10006 --10002,'2017-04-01',10022
	    --EXEC sp_SIPAC_ReporteGastos_RCCONT01M 10005, '2016-12-01', 10036
         END;