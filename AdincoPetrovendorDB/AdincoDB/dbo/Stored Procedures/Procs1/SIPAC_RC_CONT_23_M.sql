IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SIPAC_RC_CONT_23_M'
    )
    DROP PROCEDURE SIPAC_RC_CONT_23_M;
GO
-- =============================================  
-- Author:Yazmin Glez.  
-- Create date:2017-11-28  
-- Description:Reporte de CGI - Registro de CFDIs Relacionados_CONT_23_M  
-- Modificado: Reyna Olvera  
-- Fecha Modificado: 20180625  
-- Description: Se modifico para que  solo muestre los que tengan Tipo Relacion 01,02,07 y que el numero de parcialidad si es null sea 0  
-- Modificado: Manuel Cruz  
-- Fecha Modificado: 2019-07-01  
-- Description: Cambio para mostrar la relacion del principal con el complemento de pago  
-- Modificado:       Marcos Garcia  
-- Fecha Modificado: 2020-01-13  
-- Description:     *Agregar Validacion de @IdPresupuesto = 0  
--                  *Agregar WITH (NOLOCK) en las tablas   
-- =============================================  
-- Modificado:       Reyna Olvera  
-- Fecha Modificado: 2022-08-18  
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS  
-- =============================================  
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 16 de Febrero del 2023  
-- Description:      Se agrega la opción obtener el nuevo campo IDSIPAC desde la tabla CO_Contrato, si este viene vacío o nulo se obtendrá desde la tabla que ya se obtenía anteriormente CO_Contratista  
-- =============================================  
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_23_M]  
    @Contrato      INT,  
    @Mes           DATE,  
    @IdPresupuesto INT          = 0,  
    @Plantilla     VARCHAR(150) = ''  
AS  
BEGIN  
        SET NOCOUNT ON;  
		
		DECLARE @Aprobado INT = 10004,
		@TipoFactura INT = 1,
		@TipoComplementoPago INT = 6

        IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL  
            DROP TABLE #uuidNoReportar;  
  
        /*Omitir facturas en la hoja 21*/  
  
		IF OBJECT_ID('tempdb..#TEMPORAL_23_SP') IS NOT NULL
		DROP TABLE #TEMPORAL_23_SP;

		CREATE TABLE #TEMPORAL_23_SP (
			RF_00 VARCHAR(100),
			RI_00 VARCHAR(100),
			RF01_01 VARCHAR(100),
			RC23_00 INT,
			RC23_01 INT,
			RC23_02 VARCHAR(36),
			RC23_03 VARCHAR(36),
			RC23_04 VARCHAR(10),
			RC23_05 INT,
			Nota VARCHAR(4000),

			-- Datos de la nota de credito (RC23_02)
			Contrato_NC NVARCHAR(100),
			Presupuesto_NC VARCHAR(1000),
			Tarea_NC VARCHAR(1000),

			-- Datos del documento relacionado (RC23_03)
			Contrato_Relacionado NVARCHAR(100),
			Presupuesto_Relacionado VARCHAR(1000),
			Tarea_Relacionado VARCHAR(1000)
		);

        CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));  
        IF (@Mes = '20190801')  
            BEGIN  
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '091A3242-EF0F-444A-A5C1-3D7D50247D3B'  
                    ),  
                    (  
                        '775E782A-9493-3D40-9B24-E1604A865A0F'  
                    ),  
                    (  
                        '78BB3869-8091-B049-98B4-1238E15E7BDA'  
                    ),  
                    (  
                        'A6344C73-4C5A-EA4A-B2F8-3378CDA24C17'  
                    );  
            END;  
        IF (@Mes <> '20190901')  
            BEGIN  
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '9A159442-52BC-1E49-8190-D020953CE967'  
                    );  
            END;  
        IF (@Mes <> '20200101')  
            BEGIN  
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        '78CA2E37-22C0-408C-8E94-105C7388A704'  
                    ),  
                    (  
                        '30EFEC90-471E-434A-87CF-EFFEEE7C48C1'  
                    );  
            END;  
        IF (@Mes = '20200501')  
            BEGIN  
                INSERT INTO #uuidNoReportar  
                    (  
                        UUID  
                    )  
                VALUES  
                    (  
                        'D515F4A9-244C-422E-A2B1-11B234039715'  
                    ),  
                    (  
                        '1091E714-CC8E-46B8-8421-37470C285BAC'  
                    ),  
                    (  
                        '95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'  
                    ),  
                    (  
                        '10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6'  
                    );  
            END;  
  
        /**/  
  		INSERT INTO #TEMPORAL_23_SP (
			RF_00, RI_00, RF01_01, RC23_00, RC23_01,
			RC23_02, RC23_03, RC23_04, RC23_05, 
			Contrato_NC, Presupuesto_NC, Tarea_NC,
			Contrato_Relacionado, Presupuesto_Relacionado, Tarea_Relacionado
		)
        SELECT 
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN  
					LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
            END											 AS [RF_00],  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))  AS [RI_00],  
            CO_Contrato.NumeroContrato                   AS [RF01_01],  
            MONTH(CO_Registro.MesPresentacion)           AS [RC23_00],  
            YEAR(CO_Registro.MesPresentacion)            AS [RC23_01],  
            FI_Factura.UUID                              AS [RC23_02],  
            FI_CFDIRelacionados.UUID                     AS [RC23_03],  
            FI_CFDIRelacionados.TipoRelacion             AS [RC23_04],  
            ISNULL(FI_CFDIRelacionados.NoParcialidad, 0) AS [RC23_05],
			CO_Contrato.NumeroContrato, CO_Presupuesto.Nombre, TP.id_Tarea,
			contratoRelacionado.NumeroContrato, presupuestoRelacionado.Nombre, tareaRelacionada.id_Tarea 
        FROM  
            dbo.FI_Transfer WITH (NOLOCK)  
            JOIN  
                dbo.FI_TransferFactura WITH (NOLOCK)  
                    ON FI_Transfer.IdContrato = @Contrato 
					   AND FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer  
            JOIN  
                dbo.FI_Factura WITH (NOLOCK)  
                    ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura  
            JOIN  
                dbo.FI_CFDIRelacionados WITH (NOLOCK)  
                    ON FI_CFDIRelacionados.CFDIId = FI_Factura.IdFactura  
            JOIN  
                dbo.CO_Registro WITH (NOLOCK)  
                    ON CO_Registro.IdFactura = FI_Factura.IdFactura  
                       AND CO_Registro.IdEstado = @Aprobado  
                       AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            JOIN  
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
            JOIN  
                dbo.CO_Presupuesto WITH (NOLOCK)  
                    ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto  
            JOIN  
                dbo.CO_AnioContractual WITH (NOLOCK)  
                    ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual  
            JOIN  
                dbo.CO_Contrato WITH (NOLOCK)  
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                       AND CO_Contrato.IdContrato = @Contrato  
            JOIN  
                dbo.CO_Contratista WITH (NOLOCK)  
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista   
            LEFT JOIN  
                dbo.CO_Servicio WITH (NOLOCK)  
                    ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio  
                       AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
			LEFT JOIN dbo.CO_TareaPetrolera TP WITH (NOLOCK)
				ON CO_LineaPresupuestoMes.IdTareaPetrolera = TP.IdTareaPetrolera
			LEFT JOIN FI_Factura FacturaRelacionada	WITH (NOLOCK)
				ON FI_CFDIRelacionados.UUID = FacturaRelacionada.UUID
			LEFT JOIN CO_Registro registroRelacionado WITH (NOLOCK)
				ON FacturaRelacionada.IdFactura = registroRelacionado.IdFactura
			LEFT JOIN CO_LineaPresupuestoMes lineaRelacionado WITH (NOLOCK)
				ON registroRelacionado.IdPrograma = lineaRelacionado.IdLineaPresupuestoMes
			LEFT JOIN dbo.CO_TareaPetrolera tareaRelacionada WITH (NOLOCK)
				ON lineaRelacionado.IdTareaPetrolera = tareaRelacionada.IdTareaPetrolera
			LEFT JOIN CO_Presupuesto presupuestoRelacionado WITH (NOLOCK)
				ON 	lineaRelacionado.IdPresupuesto = presupuestoRelacionado.IdPresupuesto
			LEFT JOIN Co_Contrato contratoRelacionado
				ON FacturaRelacionada.IdContrato = contratoRelacionado.IdContrato
        WHERE  
            CO_Contrato.IdContrato = @Contrato  
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
            AND CO_Registro.IdEstado = @Aprobado  
            AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0  
            AND FI_CFDIRelacionados.TipoRelacion IN (  
                                                        01, 02, 07  
                                                    )  
            AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
            AND (  
                    FI_Factura.TipoComprobante LIKE '%egreso%'  
                    OR FI_Factura.TipoComprobante LIKE 'E%'  
                )  
            AND FI_Factura.UUID NOT IN (  
                                           SELECT  
                                               RPT.UUID  
                                           FROM  
												#uuidNoReportar RPT  
                                       )  
            AND FI_Factura.UUID NOT IN (  
                                           SELECT  
                                               ControlF.UUID  
                                           FROM  
                                               dbo.FI_ControlPPDComplementos ControlF WITH (NOLOCK)  
                                           WHERE  
                                               ControlF.IdContrato = @Contrato  
                                       )  
            AND CO_Presupuesto.IdPresupuesto = CASE  
                                                   WHEN @IdPresupuesto = 0  
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                   ELSE  
                                                       @IdPresupuesto  
                                               END  
        GROUP BY  
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN  
                    LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
            END,  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),  
            MONTH(CO_Registro.MesPresentacion),  
            YEAR(CO_Registro.MesPresentacion),  
            ISNULL(FI_CFDIRelacionados.NoParcialidad, 0),  
            CO_Contrato.NumeroContrato,  
            FI_Factura.UUID,  
            FI_CFDIRelacionados.UUID,  
            FI_CFDIRelacionados.TipoRelacion,
			CO_Contrato.NumeroContrato, CO_Presupuesto.Nombre, TP.id_Tarea,
			contratoRelacionado.NumeroContrato, presupuestoRelacionado.Nombre, tareaRelacionada.id_Tarea
        --  
        UNION  
        --  
        SELECT
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN  
                    LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
            END                 AS [RF_00],  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],  
            CO_Contrato.NumeroContrato                  AS [RF01_01],  
            MONTH(CO_Registro.MesPresentacion)          AS [RC23_00],  
            YEAR(CO_Registro.MesPresentacion)           AS [RC23_01],  
            FCP.UUID                                    AS [RC23_02],  
            CASE  
                WHEN FCP.TipoComprobante = 'P'  
                    THEN FCPDR.UUID  
                ELSE  
                    FCP.UUID  
            END                                         AS [RC23_03],  
            '07'                                        AS [RC23_04],  
            MAX(   CASE  
                       WHEN FCP.TipoComprobante = 'P'  
                           THEN FI_CPDocRelacionado.NumParcialidad  
                       ELSE  
                           0  
                   END  
               )                                        AS [RC23_05],
			CO_Contrato.NumeroContrato, CO_Presupuesto.Nombre, TP.id_Tarea,
			contratoRelacionado.NumeroContrato, presupuestoRelacionado.Nombre, tareaRelacionada.id_Tarea 
        FROM  
            dbo.FI_Transfer WITH (NOLOCK)  
            JOIN  
                dbo.FI_TransferFactura WITH (NOLOCK)  
                    ON FI_Transfer.IdContrato = @Contrato
					   AND FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer  
            JOIN  
                dbo.FI_ComplementoDePago WITH (NOLOCK)  
                    ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura  
            JOIN  
                dbo.FI_CPDocRelacionado WITH (NOLOCK)  
                    ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago  
            JOIN  
                dbo.FI_Factura FCP WITH (NOLOCK)  
                    ON FI_TransferFactura.IdFactura = FCP.IdFactura  
            JOIN  
                dbo.FI_Factura FCPDR WITH (NOLOCK)  
                    ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID  
            JOIN  
                dbo.CO_Registro WITH (NOLOCK)  
                    ON FCPDR.IdFactura = CO_Registro.IdFactura  
                       AND CO_Registro.IdEstado = @Aprobado  
                       AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            JOIN  
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
            JOIN  
                dbo.CO_Presupuesto WITH (NOLOCK)  
                    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto  
            JOIN  
                dbo.CO_AnioContractual WITH (NOLOCK)  
                    ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual  
            JOIN  
                dbo.CO_Contrato WITH (NOLOCK)  
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                       AND CO_Contrato.IdContrato = @Contrato  
            JOIN  
                dbo.CO_Contratista WITH (NOLOCK)  
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista  
            LEFT JOIN  
                dbo.CO_Servicio WITH (NOLOCK)  
                    ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio  
                       AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
			LEFT JOIN dbo.CO_TareaPetrolera TP WITH (NOLOCK)
				ON CO_LineaPresupuestoMes.IdTareaPetrolera = TP.IdTareaPetrolera
			LEFT JOIN dbo.FI_Factura F_Rel ON
				(
					(FCP.TipoComprobante <> 'P' AND F_Rel.UUID = FI_CPDocRelacionado.IdDocumento)
					OR
					(FCP.TipoComprobante = 'P' AND F_Rel.UUID = FCP.UUID)
				)
			LEFT JOIN FI_Factura FacturaRelacionada	WITH (NOLOCK)
				ON F_Rel.UUID = FacturaRelacionada.UUID
			LEFT JOIN CO_Registro registroRelacionado WITH (NOLOCK)
				ON FacturaRelacionada.IdFactura = registroRelacionado.IdFactura
			LEFT JOIN CO_LineaPresupuestoMes lineaRelacionado WITH (NOLOCK)
				ON registroRelacionado.IdPrograma = lineaRelacionado.IdLineaPresupuestoMes
			LEFT JOIN dbo.CO_TareaPetrolera tareaRelacionada WITH (NOLOCK)
				ON lineaRelacionado.IdTareaPetrolera = tareaRelacionada.IdTareaPetrolera
			LEFT JOIN CO_Presupuesto presupuestoRelacionado WITH (NOLOCK)
				ON 	lineaRelacionado.IdPresupuesto = presupuestoRelacionado.IdPresupuesto
			LEFT JOIN Co_Contrato contratoRelacionado
				ON FacturaRelacionada.IdContrato = contratoRelacionado.IdContrato
        WHERE  
            CO_Contrato.IdContrato = @Contrato  
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
            AND CO_Registro.IdEstado = @Aprobado  
            AND CO_Registro.CvTipoDocFacturacion = @TipoFactura  
            AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0  
            AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
            AND FCP.UUID NOT IN (  
                                    SELECT  
                                        RPT.UUID  
                                    FROM  
                                        #uuidNoReportar RPT  
                                )  
            AND FCP.UUID NOT IN (  
                                    SELECT  
                                        ControlF.UUID  
                                    FROM  
                                        dbo.FI_ControlPPDComplementos ControlF  
                                    WHERE  
                                        ControlF.IdContrato = @Contrato  
                                )  
            AND CO_Presupuesto.IdPresupuesto = CASE  
                                                   WHEN @IdPresupuesto = 0  
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                   ELSE  
                                                       @IdPresupuesto  
                                               END  
        GROUP BY  
            CASE  
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN  
                    LTRIM(RTRIM(CO_Contrato.IDSIPAC))  
                ELSE  
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))  
            END,  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),  
            MONTH(CO_Registro.MesPresentacion),  
            YEAR(CO_Registro.MesPresentacion),  
            CASE  
                WHEN FCP.TipoComprobante = 'P'  
                    THEN FCPDR.UUID  
                ELSE  
                    FCP.UUID  
            END,  
            CO_Contrato.NumeroContrato,  
            FCP.UUID,
			CO_Contrato.NumeroContrato, CO_Presupuesto.Nombre, TP.id_Tarea,
			contratoRelacionado.NumeroContrato, presupuestoRelacionado.Nombre, tareaRelacionada.id_Tarea
			

			UPDATE TMP
			SET TMP.Nota = LEFT(
				ISNULL(TMP.Nota, '') +
				CASE 
					WHEN 
						(TMP.Contrato_NC IS NOT NULL AND TMP.Contrato_Relacionado IS NOT NULL AND TMP.Contrato_NC <> TMP.Contrato_Relacionado)
						OR (TMP.Presupuesto_NC IS NOT NULL AND TMP.Presupuesto_Relacionado IS NOT NULL AND TMP.Presupuesto_NC <> TMP.Presupuesto_Relacionado)
						OR (TMP.Tarea_NC IS NOT NULL AND TMP.Tarea_Relacionado IS NOT NULL AND TMP.Tarea_NC <> TMP.Tarea_Relacionado)
					THEN 
						' Se detectó una discrepancia entre los datos de la nota de crédito ' + 
						'(Contrato: ' + ISNULL(TMP.Contrato_NC, '') +
						', Presupuesto: ' + ISNULL(TMP.Presupuesto_NC, '') + 
						', Tarea: ' + ISNULL(TMP.Tarea_NC, '') + 
						') y los del documento relacionado ' + 
						'(Contrato: ' + ISNULL(TMP.Contrato_Relacionado, '') + 
						', Presupuesto: ' + ISNULL(TMP.Presupuesto_Relacionado, '') + 
						', Tarea: ' + ISNULL(TMP.Tarea_Relacionado, '') + ').'
					ELSE ''
				END, 
			4000)
			FROM #TEMPORAL_23_SP TMP;

			SELECT	RF_00,
					RI_00,
					RF01_01,
					RC23_00,
					RC23_01,
					RC23_02,
					RC23_03,
					RC23_04,
					RC23_05,
					Nota
			FROM #TEMPORAL_23_SP

    END; 
		