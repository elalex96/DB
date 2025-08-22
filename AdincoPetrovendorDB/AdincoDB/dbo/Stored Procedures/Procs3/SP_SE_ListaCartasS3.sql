IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_SE_ListaCartasS3'
    )
    DROP PROCEDURE SP_SE_ListaCartasS3;
GO
-- =============================================  
-- Author:  Manuel CD  
-- Create date: 2018-10-16  
-- Description:   
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos	los presupuestos del periodo
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure  
--					para tomar en cuenta gastos con PCN >=0
--				    se agrego filtro de rubros (issue 1890 adinco)
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_ListaCartasS3] 
    @IdContrato    INT,
    @IdUsuario     INT,
    @IdPresupuesto INT,
    @FInicio       DATE,
    @FFin          DATE,
    @IdPeriodo     INT,
    @Etapa         VARCHAR(20)
AS
    BEGIN
        SET NOCOUNT ON;


        CREATE TABLE #Presupuestos (IdPresupuesto INT);
        CREATE TABLE #RFC (RFC VARCHAR(25));
        /*Cartas de Petrovendor*/
        CREATE TABLE #CartasPetrovendor
            (
                Identificador   VARCHAR(500),
                Carpeta         VARCHAR(500),
                Ruta            VARCHAR(500),
                Cubeta          VARCHAR(500),
                NombreDocumento VARCHAR(500),
                IdFactura       INT,
                UUID            VARCHAR(500)
            );
        /*Facturas de Adinco*/
        CREATE TABLE #FacturasAdinco
            (
                IdFactura INT,
                UUID      VARCHAR(500),
                RFC       VARCHAR(50)
            );

		DECLARE
            @Peso                                 INT = 1,
            @Dolar                                INT = 2,
            @EsPresupuestoJaguarPantera                        INT = 0,
            @EsPresupuestoGuardadosJaguarPanteraExploracion    INT = 0,
            @EsPresupuestoSeleccionadoJaguarPanteraExploracion INT = 0,
			@EstatusAprobado INT = 2,
			@Jaguar INT = 10005,	
			@Pantera INT = 10006;
        /*Se valida si el presupuesto viene en 0 para obtener todos los presupuestos del perido.*/
        IF (@IdPresupuesto = 0)
            BEGIN
                INSERT INTO #Presupuestos
                    (
                        IdPresupuesto
                    )
                            SELECT
                                CP.IdPresupuesto
                            FROM
                                CO_ProgramaActividad   CPA (NOLOCK)
                                INNER JOIN
                                    CO_PeriodoContrato CPC (NOLOCK)
                                        ON CPA.IdPeriodoContrato = CPC.IdPeriodo
										AND	CPC.IdPeriodo = @IdPeriodo
                                INNER JOIN
                                    CO_Presupuesto     CP (NOLOCK)
                                        ON CPA.IdProgramaActividad = CP.IdProgramaActividad
                            WHERE
                                CPC.IdPeriodo = @IdPeriodo
                                AND CP.Activo = 1;

								SELECT
                            @EsPresupuestoGuardadosJaguarPanteraExploracion = COUNT(1)
                        FROM
                            #Presupuestos              T
                            JOIN
                                dbo.CO_Presupuesto     P (NOLOCK)
                                    ON T.IdPresupuesto = P.IdPresupuesto
                            JOIN
                                dbo.CO_AnioContractual AC (NOLOCK)
                                    ON P.IdAnioContractual = AC.IdAnioContractual
                            JOIN
                                dbo.CO_Contrato        C (NOLOCK)
                                    ON AC.IdContrato = C.IdContrato
                        WHERE
                            P.nombre LIKE '%exploración%'
                            AND C.IdContratista IN (
                                                      @Jaguar, @Pantera
                                                   )
	IF (1 = @EsPresupuestoGuardadosJaguarPanteraExploracion)
                    BEGIN
                        DELETE FROM #Presupuestos
                        INSERT INTO #Presupuestos
                            (
                                IdPresupuesto
                            )
                                    SELECT
                                        P.IdPresupuesto
                                    FROM
                                        dbo.CO_Presupuesto         P (NOLOCK)
                                        JOIN
                                            dbo.CO_AnioContractual AC (NOLOCK)
                                                ON P.IdAnioContractual = AC.IdAnioContractual
												   AND P.nombre LIKE '%exploración%'
												     AND	AC.IdContrato = @IdContrato
                                        JOIN
                                            dbo.CO_Contrato        C (NOLOCK)
                                                ON AC.IdContrato = C.IdContrato
                                    WHERE
                                        C.IdContrato = @IdContrato
                                        AND P.nombre LIKE '%exploración%'
                                        AND C.IdContratista IN (
                                                                   @Jaguar, @Pantera
                                                               );
                    END;
            END
        ELSE
            BEGIN

			     SELECT
                            @EsPresupuestoSeleccionadoJaguarPanteraExploracion = COUNT(1)
                        FROM
                            dbo.CO_Presupuesto         P (NOLOCK)
                            JOIN
                                dbo.CO_AnioContractual AC (NOLOCK)
                                    ON P.IdAnioContractual = AC.IdAnioContractual
									AND	P.IdPresupuesto = @IdPresupuesto
									AND P.Nombre LIKE '%exploración%'
                            JOIN
                                dbo.CO_Contrato        C (NOLOCK)
                                    ON AC.IdContrato = C.IdContrato
                        WHERE
                            P.IdPresupuesto = @IdPresupuesto
                            AND P.Nombre LIKE '%exploración%'
                            AND C.IdContratista IN (
                                                       @Jaguar, @Pantera
                                                   );

IF (1 = @EsPresupuestoSeleccionadoJaguarPanteraExploracion)
                    BEGIN
                        INSERT INTO #Presupuestos
                            (
                                IdPresupuesto
                            )
                                    SELECT
                                        P.IdPresupuesto
                                    FROM
                                        dbo.CO_Presupuesto         P (NOLOCK)
                                        JOIN
                                            dbo.CO_AnioContractual AC (NOLOCK)
                                                ON P.IdAnioContractual = AC.IdAnioContractual
												 AND P.Nombre LIKE '%exploración%'
												 AND AC.IdContrato = @IdContrato
                                        JOIN
                                            dbo.CO_Contrato        C (NOLOCK)
                                                ON AC.IdContrato = C.IdContrato
                                    WHERE
                                        C.IdContrato = @IdContrato
                                        AND P.Nombre LIKE '%exploración%'
                                        AND C.IdContratista IN (
                                                                   @Jaguar, @Pantera
                                                               );
                    END;
                ELSE
                    BEGIN
                        INSERT INTO #Presupuestos
                            (
                                IdPresupuesto
                            )
                                    SELECT
                                        @IdPresupuesto;

                    END;
            END

        /*RFC*/
        INSERT INTO #RFC
            (
                RFC
            )
             VALUES
            (
                'FMP140930MW3'
            ),
            (
                'SAT970701NN3'
            );

			SELECT
                   @EsPresupuestoJaguarPantera = COUNT(1)
                FROM
                    dbo.CO_Presupuesto         P (NOLOCK)
                    JOIN
                        dbo.CO_AnioContractual AC (NOLOCK)
                            ON P.IdAnioContractual = AC.IdAnioContractual
							AND P.idpresupuesto = @IdPresupuesto
                    JOIN
                        dbo.CO_Contrato        C (NOLOCK)
                            ON AC.IdContrato = C.IdContrato
                WHERE
                    P.idpresupuesto = @IdPresupuesto
                    AND C.IdContratista IN (
                                              @Jaguar, @Pantera
                                           )
		IF (@EsPresupuestoJaguarPantera > 0)
            BEGIN
                INSERT INTO #RFC
                    (
                        RFC
                    )
                       VALUES
                    (
                        'FMO930803PB1'
                    ),
                    (
                        'GMS971110BTA'
                    );
            END;

        INSERT INTO #FacturasAdinco
            (
                IdFactura,
                UUID,
                RFC
            )
                    SELECT DISTINCT
                        F.IdFactura,
                        F.UUID,
                        S.RFC
                    FROM
                       #Presupuestos                           PP
                        JOIN
                            Adinco.dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                                ON PP.IdPresupuesto = L.IdPresupuesto
                        JOIN
                            Adinco.dbo.CO_Registro              R (NOLOCK)
                                ON L.IdLineaPresupuestoMes = R.IdPrograma
                        JOIN
                            Adinco.dbo.FI_Factura               F (NOLOCK)
                                ON R.IdFactura = F.IdFactura
                                   AND F.IdContrato = @IdContrato
						JOIN
                            Adinco.dbo.PV_Subcontratista        S (NOLOCK)
                                ON S.IdSubcontratista = F.IdSubcontratista
                        JOIN
                            Adinco.dbo.CO_TipoCambioDiario      TCD (NOLOCK)
                                ON F.IdMoneda <> TCD.IdMoneda
                                   AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                   AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                   AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                        LEFT JOIN
                            Adinco.dbo.MM_BS_Actividad          A (NOLOCK)
                                ON R.IdCBSISH = A.IdActividad
                    WHERE
                        (
                            CAST(F.Fecha AS DATE) >= @FInicio
                            AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
                        )
                        AND S.RFC NOT IN (
                                             SELECT
                                                 RFC
                                             FROM
                                                 #RFC
                                         )
                        AND F.IdContrato = @IdContrato
                        AND ISNULL(R.PCN, 0) >= 0
                        AND TCD.IdMoneda IN (
                                                1, 2
                                            )
                        AND R.IdGastoRubro IN (
                                                  1, 2, 3, 4, 5
                                              )
                        AND (
                                F.IdFactura IS NOT NULL
                                AND F.UUID IS NOT NULL
                                AND F.UUID <> ''
                            );

        INSERT INTO #CartasPetrovendor
            (
                Identificador,
                Carpeta,
                Ruta,
                Cubeta,
                NombreDocumento,
                IdFactura,
                UUID
            )
                    SELECT
                        DOC.Identificador,
                        DOC.Carpeta,
                        CONCAT(DOC.Carpeta, DOC.Identificador) AS Ruta,
                        'petrovendor-pr'                       AS Cubeta,
                        CONCAT(
                                  'CCN-', VEN.TaxID COLLATE DATABASE_DEFAULT, '-',
                                  ROW_NUMBER() OVER (ORDER BY
                                                         DOC.Identificador
                                                    ), '.pdf'
                              )                                AS NombreDocumento,
                        AF.IdFactura,
                        FP.UUID
                  FROM
                        #FacturasAdinco                                    FA
                        JOIN
                            Petrovendor.dbo.FI_Factura                     FP (NOLOCK)
                                on FA.UUID = FP.uuid collate SQL_Latin1_General_CP1_CI_AS
                        JOIN
                            Petrovendor.dbo.MPY_MM_Aceptacionfactura       AF (NOLOCK)
                                on FP.IdFactura = AF.IdFactura
						 JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionPedido        AS AP (NOLOCK)
                                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
						JOIN
                        Petrovendor.dbo.MPY_MM_AceptacionCartaPCN          AS ACCN (NOLOCK)
							on AP.IdAceptacionPedido = ACCN.IdAceptacionPedido
                                   AND ACCN.IdEstatus = @EstatusAprobado
                        JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD
                                on AP.IdAceptacionPedido = APD.IdAceptacionPedido
                        JOIN
                            Petrovendor.dbo.S_Documento_S3                 AS DOC (NOLOCK)
                                ON DOC.IdDocumento = ACCN.IdDocumento
                        JOIN
                            Adinco.dbo.CO_SAPVendor                        AS VEN (NOLOCK)
                                ON AP.IdSubContratista COLLATE DATABASE_DEFAULT = VEN.VendorIDSAP
                        
                    
                    WHERE
                        AP.IdContrato = @IdContrato
                        AND (
                                CAST(FP.Fecha AS DATE) >= @FInicio
                                AND CAST(FP.Fecha AS DATE) <= EOMONTH(@FFin)
                            )
                        AND (
                                FP.IdFactura IS NOT NULL
                                AND FP.UUID IS NOT NULL
                                AND FP.UUID <> ''
                            )
                    ----------------
                    UNION
                    ----------------  
                    SELECT
                        D.Identificador,
                        D.Carpeta,
                        CONCAT(D.Carpeta, D.Identificador) AS Ruta,
                        'petrovendor-pr'                   AS Cubeta,
                        CONCAT(
                                  'CCN-', PR.RFC COLLATE DATABASE_DEFAULT, '-',
                                  ROW_NUMBER() OVER (ORDER BY
                                                         D.Identificador
                                                    ), '.pdf'
                              )                            AS NombreDocumento,
                        AF.IdFactura,
                        FP.UUID
                    FROM
                        Petrovendor.dbo.MM_AceptacionCartaPCN    AS AC (NOLOCK)
                        JOIN
                            Petrovendor.dbo.S_Documento_S3       AS D (NOLOCK)
                                ON D.IdDocumento = AC.IdDocumento
                                   AND AC.IdEstatus = @EstatusAprobado
                                   AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                        JOIN
                            Petrovendor.dbo.MM_AceptacionPedido  AS AP (NOLOCK)
                                ON  AC.IdAceptacionPedido	=	AP.IdAceptacionPedido 
                        JOIN
                            Petrovendor.dbo.MM_Pedido            AS P (NOLOCK)
                                ON AP.IdPedido	=	 P.IdPedido 
                        JOIN
                            Petrovendor.dbo.S_Proveedor          AS PR (NOLOCK)
                                ON P.IdSubcontratista	=	PR.IdProveedor 
                        JOIN
                            Petrovendor.dbo.S_TipoValidacionDoc  AS TD (NOLOCK)
                                ON AC.IdEstatus= TD.IdTipoValidacionDoc
                        JOIN
                            Petrovendor.dbo.MM_Pedidos           AS PG (NOLOCK)
                                ON P.IdPedido = PG.IdIdentificador
                        LEFT JOIN
                            Petrovendor.dbo.MM_TipoPedido        AS TP (NOLOCK)
                                ON TP.IdTipoPedido = PG.IdTipoPedido
                        LEFT JOIN
                            Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
                                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                        LEFT JOIN
                            Petrovendor.dbo.FI_Factura           FP (NOLOCK)
                                ON FP.IdFactura = AF.IdFactura
                                   AND FP.UUID IS NOT NULL
                                   AND FP.Activa = 1
                                   AND ISNULL(FP.IsEliminado, 0) <> 1
                    WHERE
                        FP.UUID IN (
                                       SELECT
                                           UUID COLLATE DATABASE_DEFAULT
                                       FROM
                                           #FacturasAdinco
                                   )
                    GROUP BY
                        D.Identificador,
                        D.Carpeta,
                        CONCAT(D.Carpeta, D.Identificador),
                        PR.RFC,
                        AF.IdFactura,
                        FP.UUID;

        --SELECT * FROM #CartasPetrovendor
        --SELECT * FROM #FacturasAdinco

        /*Consulta final*/
        SELECT
            UPPER(D.UUIDAmazon) AS Identificador,
            CASE
                WHEN CHARINDEX('/', D.Folder) > 0
                    THEN D.Folder
                ELSE
                    CONCAT(D.Folder, '/')
            END                 AS Carpeta,
            CONCAT(   CASE
                          WHEN CHARINDEX('/', D.Folder) > 0
                              THEN D.Folder
                          ELSE
                              CONCAT(D.Folder, '/')
                      END, D.UUIDAmazon
                  )             AS Ruta,
            D.Bucket            AS Cubeta,
            CONCAT(   'CCN-', FA.RFC, '-', ROW_NUMBER() OVER (ORDER BY
                                                                  D.UUIDAmazon
                                                             ), '.pdf'
                  )             AS NombreDocumento,
            FA.IdFactura,
            FA.UUID
        FROM
            #FacturasAdinco         FA
            JOIN
                AWS_DocAwsDocAdinco DAD (NOLOCK)
                    ON FA.IdFactura = DAD.IdDocAdinco
            JOIN
                dbo.AWS_Documentos  D (NOLOCK)
                    ON DAD.AWSDocumentoId = D.AWSDocumentoId
        WHERE
            FA.UUID NOT IN (
                               SELECT
                                   UUID
                               FROM
                                   #CartasPetrovendor
                           )
        ----------------
        UNION
        ----------------
        SELECT
            Identificador,
            Carpeta,
            Ruta,
            Cubeta,
            NombreDocumento,
            IdFactura,
            UUID
        FROM
            #CartasPetrovendor
        ORDER BY
            Carpeta;
    END;

