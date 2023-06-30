CREATE PROCEDURE RealizarComercializaciones50Porciento
    @IdContrato INT,
    @MesReporte DATETIME,
    @IdUsuario INT
AS
BEGIN
    DECLARE @ErrorMessage varchar(1000) = ''

    IF NOT EXISTS
    (
        SELECT TOP 1
            1
        FROM COM_OperacionComercializacion
        WHERE IdContrato = @IdContrato
              AND MesReporte = @MesReporte
              AND ISNULL(CostoUnitarioComercializacion, 0) = 0
              AND ISNULL(EPT, 0) = 0
    )
    BEGIN
        SELECT 'Primero se debe de generar las comercializaciones del mes seleccionado'
    END
    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRAN tranComercializacion

            CREATE TABLE #Actualizar
            (
                Hidrocarburo varchar(2000),
                Volumen float
            )
            CREATE TABLE #AjusteDeAcuerdoAlPorcentaje
            (
                Descripcion varchar(4000),
                Petroleo float,
                Metano float,
                Etano float,
                Propano float,
                Butano float,
                Condensado float
            )
            CREATE TABLE #PorcentajeDeParticipacion
            (
                Descripcion varchar(4000),
                Petroleo float,
                Metano float,
                Etano float,
                Propano float,
                Butano float,
                Condensado float
            )
            CREATE TABLE #ComercializacionPorPuntoEntrega
            (
                Descripcion varchar(100),
                Petroleo float,
                Metano float,
                Etano float,
                Propano float,
                Butano float,
                Condensado float
            )
            CREATE TABLE #Comercializacion
            (
                Descripcion varchar(100),
                Petroleo float,
                Metano float,
                Etano float,
                Propano float,
                Butano float,
                Condensado float
            )
            CREATE TABLE #VendidoPorHidrocarburo
            (
                Hidrocarburo varchar(2000),
                Vendido float,
                Actualizar bit
            )
            DECLARE @PorcentajeSocio DECIMAL(6, 2) = 0,
                    @PetroleoComercializacion float = 0,
                    @MetanoComercializacion float = 0,
                    @EtanoComercializacion float = 0,
                    @PropanoComercializacion float = 0,
                    @ButanoComercializacion float = 0,
                    @CondensadoComercializacion float = 0,
                    @PetroleoDiferenciaVolumen float = 0,
                    @MetanoDiferenciaVolumen float = 0,
                    @EtanoDiferenciaVolumen float = 0,
                    @PropanoDiferenciaVolumen float = 0,
                    @ButanoDiferenciaVolumen float = 0,
                    @CondensadoDiferenciaVolumen float = 0

            SELECT @PorcentajeSocio = ISNULL(PorcentajeSocio, 0) / 100
            FROM CO_PorcentajesContrato
            WHERE IdContrato = @IdContrato



            INSERT INTO #Comercializacion
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT 'VOLUMEN MENSUAL PRODUCIDO',
                   VolumenPetroleoPuntoMedicion,
                   MetanoC1,
                   EtanoC2,
                   PropanoC3,
                   ButanoC4,
                   VolumenCondensadoPuntoMedicion
            FROM PR_VolumenMensualProduccionPetroleo
            WHERE IdContrato = @Idcontrato
                  AND MesReporte = @MesReporte
				  AND Activo = 1



            INSERT INTO #Comercializacion
            (
                Descripcion,
                Petroleo,
    Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT 'PORCENTAJE ABSOLUTO CORRESPONDIENTE A PCM',
                   ISNULL(Petroleo, 0) * ISNULL(@PorcentajeSocio, 0),
                   ISNULL(Metano, 0) * ISNULL(@PorcentajeSocio, 0),
                   ISNULL(Etano, 0) * ISNULL(@PorcentajeSocio, 0),
                   ISNULL(Propano, 0) * ISNULL(@PorcentajeSocio, 0),
                   ISNULL(Butano, 0) * ISNULL(@PorcentajeSocio, 0),
                   ISNULL(Condensado, 0) * ISNULL(@PorcentajeSocio, 0)
            FROM #Comercializacion
            WHERE Descripcion = 'VOLUMEN MENSUAL PRODUCIDO'



            INSERT INTO #VendidoPorHidrocarburo
            (
                Hidrocarburo,
                Vendido
            )
            SELECT CO_TipoHidrocarburo.Hidrocarburo,
                   SUM(VolumenVendido) Vendido
            FROM COM_OperacionComercializacion
                INNER JOIN CO_TipoHidrocarburo
                    ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
            WHERE COM_OperacionComercializacion.IdContrato = @IdContrato
                  AND COM_OperacionComercializacion.MesReporte = @MesReporte
                  AND ISNULL(COM_OperacionComercializacion.CostoUnitarioComercializacion, 0) = 0
                  AND ISNULL(COM_OperacionComercializacion.EPT, 0) = 0
            GROUP BY CO_TipoHidrocarburo.Hidrocarburo



            SELECT @PetroleoComercializacion = ISNULL([Petróleo], 0),
                   @CondensadoComercializacion = ISNULL([Condensado], 0),
                   @MetanoComercializacion = ISNULL([Metano], 0),
                   @EtanoComercializacion = ISNULL([Etano], 0),
                   @PropanoComercializacion = ISNULL([Propano], 0),
                   @ButanoComercializacion = ISNULL([Butano], 0)
            FROM
            (
                SELECT Hidrocarburo,
                       Vendido
                FROM #VendidoPorHidrocarburo
            ) AS TableToPivot
            PIVOT
            (
                SUM(Vendido)
                FOR Hidrocarburo IN ([Petróleo], [Condensado], [Metano], [Etano], [Propano], [Butano])
            ) AS PivotTable;



            INSERT INTO #Comercializacion
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT 'COMERCIALIZACION PCM',
                   @PetroleoComercializacion,
                   @MetanoComercializacion,
                   @EtanoComercializacion,
                   @PropanoComercializacion,
                   @ButanoComercializacion,
                   @CondensadoComercializacion



            INSERT INTO #Comercializacion
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT 'DIFERENCIA EN PORCENTAJE',
                   CAST(((@PetroleoComercializacion / Petroleo) * 100) AS money),
                   CAST(((@MetanoComercializacion / Metano) * 100) AS money),
                   CAST(((@EtanoComercializacion / Etano) * 100) AS money),
                   CAST(((@PropanoComercializacion / Propano) * 100) AS money),
                   CAST(((@ButanoComercializacion / Butano) * 100) AS money),
                   CAST(((@CondensadoComercializacion / Condensado) * 100) AS money)
            FROM #Comercializacion
            WHERE Descripcion = 'VOLUMEN MENSUAL PRODUCIDO'



            INSERT INTO #Comercializacion
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
  Propano,
                Butano,
                Condensado
            )
            SELECT 'DIFERENCIA EN VOLUMEN',
                    ROUND(CAST((Petroleo - @PetroleoComercializacion) AS money), 0),
					ROUND(CAST((Metano - @MetanoComercializacion) AS money), 0),
					ROUND(CAST((Etano - @EtanoComercializacion) AS money), 0),
					ROUND(CAST((Propano - @PropanoComercializacion) AS money), 0),
					ROUND(CAST((Butano - @ButanoComercializacion) AS money), 0),
					ROUND(CAST((Condensado - @CondensadoComercializacion) AS money),0)
            FROM #Comercializacion
            WHERE Descripcion = 'PORCENTAJE ABSOLUTO CORRESPONDIENTE A PCM'



            INSERT INTO #ComercializacionPorPuntoEntrega
            (
                Descripcion,
                Petroleo,
                Condensado,
                Metano,
                Etano,
                Propano,
                Butano
            )
            select CONCAT('', Nombre),
                   ISNULL([Petróleo], 0) [Petróleo],
                   ISNULL([Condensado], 0) [Condensado],
                   ISNULL([Metano], 0) [Metano],
                   ISNULL([Etano], 0) [Etano],
                   ISNULL([Propano], 0) [Propano],
                   ISNULL([Butano], 0) [Butano]
            from
            (
                SELECT CO_PuntosdeEntrega.Nombre,
                       CO_TipoHidrocarburo.Hidrocarburo,
                       COM_OperacionComercializacion.VolumenVendido Vendido
                FROM COM_OperacionComercializacion
                    INNER JOIN CO_PuntosdeEntrega
                        on COM_OperacionComercializacion.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
                    INNER JOIN CO_TipoHidrocarburo
                        ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
                WHERE IdContrato = @Idcontrato
                      AND ISNULL(COM_OperacionComercializacion.CostoUnitarioComercializacion, 0) = 0
                      AND ISNULL(COM_OperacionComercializacion.EPT, 0) = 0 --Comercializaciones que pertenecen a PCM
                      AND MesReporte = @MesReporte
                GROUP BY CO_PuntosdeEntrega.Nombre,
                         CO_TipoHidrocarburo.Hidrocarburo,
                         COM_OperacionComercializacion.VolumenVendido
            ) AS TableToPivot
            PIVOT
            (
                SUM(Vendido)
                FOR Hidrocarburo IN ([Petróleo], [Condensado], [Metano], [Etano], [Propano], [Butano])
            ) AS PivotTable;



            INSERT INTO #PorcentajeDeParticipacion
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT Descripcion,
                   CAST(((Petroleo / @PetroleoComercializacion) * 100) AS money) AS Petroleo,
                   CAST(((Metano / @MetanoComercializacion) * 100) AS money) AS Metano,
                   CAST(((Etano / @EtanoComercializacion) * 100) AS money) AS Etano,
                   CAST(((Propano / @PropanoComercializacion) * 100) AS money) AS Propano,
                   CAST(((Butano / @ButanoComercializacion) * 100) AS money) AS Butano,
                   CAST(((Condensado / @CondensadoComercializacion) * 100) AS money) AS Condensado
            FROM #ComercializacionPorPuntoEntrega



            SELECT @PetroleoDiferenciaVolumen = Petroleo,
                   @MetanoDiferenciaVolumen = Metano,
                   @EtanoDiferenciaVolumen = Etano,
                   @PropanoDiferenciaVolumen = Propano,
                   @ButanoDiferenciaVolumen = Butano,
                   @CondensadoDiferenciaVolumen = Condensado
            FROM #Comercializacion
            WHERE Descripcion = 'DIFERENCIA EN VOLUMEN'



            INSERT INTO #AjusteDeAcuerdoAlPorcentaje
            (
                Descripcion,
                Petroleo,
                Metano,
                Etano,
                Propano,
                Butano,
                Condensado
            )
            SELECT Descripcion,
                   ROUND(@PetroleoDiferenciaVolumen * (Petroleo/100), 0),
					ROUND(@MetanoDiferenciaVolumen * (Metano/100), 0),
					ROUND(@EtanoDiferenciaVolumen * (Etano/100), 0),
					ROUND(@PropanoDiferenciaVolumen * (Propano/100), 0),
					ROUND(@ButanoDiferenciaVolumen * (Butano/100), 0),
					ROUND(@CondensadoDiferenciaVolumen * (Condensado/100), 0)
            FROM #PorcentajeDeParticipacion



            INSERT INTO #Actualizar
            (
                Hidrocarburo,
                Volumen
            )
            SELECT Hidrocarburo,
                   Volumen
            FROM
            (
                SELECT Petroleo,
                       Metano,
                       Etano,
                       Propano,
                       Butano,
                       Condensado
                FROM #Comercializacion
                WHERE Descripcion = 'DIFERENCIA EN VOLUMEN'
            ) p UNPIVOT(Volumen FOR Hidrocarburo IN(Petroleo, Metano, Etano, Propano, Butano, Condensado)) AS unpivotTable;



            UPDATE #VendidoPorHidrocarburo
            SET Actualizar = CASE
                                 WHEN Volumen > 0 THEN
                                     1
                                 ELSE
                                     0
                             END
            FROM #VendidoPorHidrocarburo
                INNER JOIN #Actualizar
                    ON #VendidoPorHidrocarburo.Hidrocarburo COLLATE Latin1_general_CI_AI = #Actualizar.Hidrocarburo COLLATE Latin1_general_CI_AI




            IF NOT EXISTS
            (
                SELECT 1
                FROM COM_OperacionComercializacion
                    INNER JOIN CO_PuntosdeEntrega
                        on COM_OperacionComercializacion.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
                    INNER JOIN CO_TipoHidrocarburo
                        ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
                    INNER JOIN #AjusteDeAcuerdoAlPorcentaje
                        ON CO_PuntosdeEntrega.Nombre = #AjusteDeAcuerdoAlPorcentaje.Descripcion
                    INNER JOIN #VendidoPorHidrocarburo
                        ON CO_TipoHidrocarburo.Hidrocarburo = #VendidoPorHidrocarburo.Hidrocarburo
                WHERE IdContrato = @Idcontrato
                      AND ISNULL(COM_OperacionComercializacion.CostoUnitarioComercializacion, 0) = 0
                      AND ISNULL(COM_OperacionComercializacion.EPT, 0) = 0 --Comercializaciones que pertenecen a PCM
                      AND MesReporte = @MesReporte
                      AND #VendidoPorHidrocarburo.Actualizar = 1
            )
            BEGIN
                SELECT @ErrorMessage
                    = 'Se proceso la Comercialización, pero no fue necesario actualizar ningún registro'
            END



            UPDATE COM_OperacionComercializacion
            SET COM_OperacionComercializacion.VolumenVendido = CASE
                                                                   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Butano' THEN
                                                                       COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Butano
                                                                   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Condensado' THEN
                                                                       COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Condensado
                                                                   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Etano' THEN
                                                                       COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Etano
                                                                   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Metano' THEN
                                                                       COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Metano
																   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Petróleo' THEN
																		COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Petroleo
                                                                   WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Propano' THEN
                                                                       COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Propano
                                                               END,
                ModificadoEl = GETDATE(),
                ModificadoPor = @IdUsuario
            FROM COM_OperacionComercializacion
                INNER JOIN CO_PuntosdeEntrega
                    on COM_OperacionComercializacion.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
                INNER JOIN CO_TipoHidrocarburo
                    ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
                INNER JOIN #AjusteDeAcuerdoAlPorcentaje
                    ON CO_PuntosdeEntrega.Nombre = #AjusteDeAcuerdoAlPorcentaje.Descripcion
                INNER JOIN #VendidoPorHidrocarburo
                    ON CO_TipoHidrocarburo.Hidrocarburo = #VendidoPorHidrocarburo.Hidrocarburo
            WHERE IdContrato = @Idcontrato
                  AND ISNULL(COM_OperacionComercializacion.CostoUnitarioComercializacion, 0) = 0
                  AND ISNULL(COM_OperacionComercializacion.EPT, 0) = 0 --Comercializaciones que pertenecen a PCM
                  AND MesReporte = @MesReporte
                  AND #VendidoPorHidrocarburo.Actualizar = 1

            COMMIT TRAN tranComercializacion
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN tranComercializacion

            SELECT @ErrorMessage = ERROR_MESSAGE()
        END CATCH;
    END


    SELECT @ErrorMessage ERROR
    SELECT *
    FROM #Comercializacion
    SELECT '#ComercializacionPorPuntoEntrega',*
    FROM #ComercializacionPorPuntoEntrega
    SELECT '#PorcentajeDeParticipacion', *
    FROM #PorcentajeDeParticipacion
    SELECT '#VolumenQueSeAjustaraDeAcuerdoAlPorcentaje',*
    FROM #AjusteDeAcuerdoAlPorcentaje

    SELECT IdOperacionComercializacion,
			CO_PuntosdeEntrega.Nombre,
           CO_TipoHidrocarburo.Hidrocarburo,
           CASE
               WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Butano' THEN
                   COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Butano
               WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Condensado' THEN
                   COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Condensado
               WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Etano' THEN
                   COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Etano
               WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Metano' THEN
                   COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Metano
				WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Petróleo' THEN
					COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Petroleo
               WHEN CO_TipoHidrocarburo.Hidrocarburo = 'Propano' THEN
                   COM_OperacionComercializacion.VolumenVendido + #AjusteDeAcuerdoAlPorcentaje.Propano
           END VolumenActualizado
    FROM COM_OperacionComercializacion
        INNER JOIN CO_PuntosdeEntrega
            on COM_OperacionComercializacion.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
        INNER JOIN CO_TipoHidrocarburo
            ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
        INNER JOIN #AjusteDeAcuerdoAlPorcentaje
            ON CO_PuntosdeEntrega.Nombre = #AjusteDeAcuerdoAlPorcentaje.Descripcion
        INNER JOIN #VendidoPorHidrocarburo
            ON CO_TipoHidrocarburo.Hidrocarburo = #VendidoPorHidrocarburo.Hidrocarburo
    WHERE IdContrato = @Idcontrato
          AND ISNULL(COM_OperacionComercializacion.CostoUnitarioComercializacion, 0) = 0
          AND ISNULL(COM_OperacionComercializacion.EPT, 0) = 0 --Comercializaciones que pertenecen a PCM
          AND MesReporte = @MesReporte
          AND #VendidoPorHidrocarburo.Actualizar = 1
END
