IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto'
)
    DROP PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto;
GO

CREATE PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT,
    @IdContratoSeleccionado INT,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Programa VARCHAR(100),
    @Presupuesto VARCHAR(100),
    @AdjuntarClaveSubtarea BIT = 0,
    @Table_CO_Type_BitacoraPresupuestoDetalle CO_Type_BitacoraPresupuestoDetalle READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN
		SET NOCOUNT ON;  

        DECLARE @ErrorMessage VARCHAR(4000),
                @DetalleAnalisis VARCHAR(8000),
                @DetalleAnalisisServicios VARCHAR(8000),
                @DetalleAnalisisInstalaciones VARCHAR(8000),
                @IdCarga INT = 0,
                @IdAreaContractual INT = 0,
                @NumeroAlertasServicio INT = 0,
                @NumeroAlertasInstalacion INT = 0,
                @Mensaje VARCHAR(50) = '';

        SELECT TOP 1
            @IdAreaContractual = IdAreaContractual
        FROM CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContratoSeleccionado

        CREATE TABLE #TablaTemporalValidacionServicio
        (
            IdSubtarea VARCHAR(100) NULL,
            Subtarea_Servicio VARCHAR(1000) NULL,
            Existe BIT NULL,
            Activo BIT NULL,
            NumeroRepetidas INT NULL
        )

        CREATE TABLE #TablaTemporalValidacionInstalacion
        (
            Pozo_Instalacion VARCHAR(100) NULL,
            Existe BIT NULL,
            Activo BIT NULL,
            NumeroRepetidas INT NULL
        )

        CREATE TABLE #TablaTemporalValidacionDetalles
        (
            Tipo VARCHAR(100) NULL,
            Descripcion VARCHAR(1000) NULL
        )

        INSERT INTO CO_BitacoraPresupuesto
        (
            IdArchivoAWS,
            IdContrato,
            Inicio,
            Fin,
            CreadoEl,
            CreadoPor
        )
        VALUES
        (@IdArchivoAWS, @IdContratoSeleccionado, @FechaInicio, @FechaFin, GETDATE(), @UsuarioId)

        SELECT @IdCarga = SCOPE_IDENTITY()

        INSERT INTO CO_BitacoraPresupuestoDetalle
        (
            IdCarga,
            IdDetalle,
            IdActividadPetrolera,
            ActividadPetrolera,
            IdSubactividadPetrolera,
            SubactividadPetrolera,
            IdTarea,
            Tarea,
            IdSubtarea,
            Subtarea_Servicio,
            Elegible,
            Area,
            Campo,
            Yacimiento,
            Pozo_Instalacion,
            CAPEX_OPEX,
            PA_17,
            PA_18,
            PA_19,
            PA_20,
            PA_21,
            PA_22,
            PA_23,
            PA_24,
            PA_25,
            PA_26,
            PA_27,
            PA_28,
            PA_29,
            PA_30,
            PA_31,
            PA_32,
            PA_33,
            PA_34,
            PA_35,
            PA_36,
            PA_37,
            PA_38,
            PA_39,
            PA_40,
            PA_41,
            PA_42,
            PA_43,
            PA_44,
            PA_45,
            PA_46,
            PA_47,
            PA_48,
            PA_49,
            PA_50,
            PA_51,
            PA_52,
            PA_53,
            PA_54,
            PA_55,
            PA_56,
            PA_57,
            PA_58,
            PA_59,
            PA_60,
            PA_61,
            PA_62,
            PA_63,
            PA_64,
            PA_65,
            PA_66,
            PA_67,
            PA_68,
            PA_69,
            PA_70,
            PA_71,
            PA_72,
            PA_73,
            PA_74,
            PA_75,
            PA_76,
            PA_77,
            PA_78,
            PA_79,
            PA_80,
            PA_81,
            PA_82,
            PA_83,
            PA_84,
            PA_85,
            PA_86,
            PA_87,
            PA_88,
            PA_89,
            PA_90,
            PA_91,
            PA_92,
            PA_93,
            PA_94,
            PA_95,
            PA_96,
            PA_97,
            PA_98,
            PA_99,
            PA_100,
            PA_101,
            PA_102,
            PA_103,
            PA_104,
            PA_105,
            PA_106,
            PA_107,
            PA_108,
            PA_109,
            PA_110,
            PA_111,
            PA_112,
            PA_113,
            PA_114,
            PA_115,
            PA_116,
            PA_117,
            PA_118,
            PA_119,
            PA_120,
            PA_121,
            PA_122,
            PA_123,
            PA_124,
            PA_125,
            PA_126,
            PA_127,
            PA_128,
            PA_129,
            PA_130,
            PA_131,
            PA_132,
            PA_133,
            PA_134,
            PA_135,
            PA_136,
            PA_137,
            PA_138,
            PA_139,
            PA_140,
            PA_141,
            PA_142,
            PA_143,
            PA_144,
            PA_145,
            PA_146,
            PA_147,
            PA_148,
            PA_149,
            PA_150,
            PA_151,
            PA_152,
            PA_153,
            PA_154,
            PA_155,
            PA_156,
            PA_157,
            PA_158,
            PA_159,
            PA_160,
            PA_161,
            PA_162,
            PA_163,
            PA_164,
            PA_165,
            PA_166,
            PA_167,
            PA_168,
            PA_169,
            PA_170,
            PA_171,
            PA_172,
            PA_173,
            PA_174,
            PA_175,
            PA_176,
            PA_177,
            PA_178,
            PA_179,
            PA_180,
            PA_181,
            PA_182,
            PA_183,
            PA_184,
            PA_185,
            PA_186,
            PA_187,
            PA_188,
            PA_189,
            PA_190,
            PA_191,
            PA_192,
            PA_193,
            PA_194,
            PA_195,
            PA_196,
            PA_197,
            PA_198,
            PA_199,
            PA_200,
            PA_201,
            PA_202,
            PA_203,
            PA_204,
            PA_205,
            PA_206,
            PA_207,
            PA_208,
            PA_209,
            PA_210,
            PA_211,
            PA_212,
            PA_213,
            PA_214,
            PA_215,
            PA_216,
            PA_217,
            PA_218,
            PA_219,
            PA_220,
            PA_221,
            PA_222,
            PA_223,
            PA_224,
            PA_225,
            PA_226,
            PA_227,
            PA_228,
            PA_229,
            PA_230,
            PA_231,
            PA_232,
            PA_233,
            PA_234,
            PA_235,
            PA_236,
            PA_237,
            PA_238,
            PA_239,
            PA_240,
            PA_241,
            PA_242,
            PA_243,
            PA_244,
            PA_245,
            PA_246,
            PA_247,
            PA_248,
            PA_249,
            PA_250,
            PA_251,
            PA_252,
            PA_253,
            PA_254,
            PA_255,
            PA_256,
            PA_257,
            PA_258,
            PA_259,
            PA_260,
            PA_261,
            PA_262,
            PA_263,
            PA_264,
            PA_265,
            PA_266,
            PA_267,
            PA_268,
            PA_269,
            PA_270,
            PA_271,
            PA_272,
            PA_273,
            PA_274,
            PA_275,
            PA_276,
            PA_277,
            PA_278,
            PA_279,
            PA_280,
            PA_281,
            PA_282,
            PA_283,
            PA_284,
            PA_285,
            PA_286,
            PA_287,
            PA_288,
            PA_289,
            PA_290,
            PA_291,
            PA_292,
            PA_293,
            PA_294,
            PA_295,
            PA_296,
            PA_297,
            PA_298,
            PA_299,
            PA_300,
            PA_301,
            PA_302,
            PA_303,
            PA_304
        )
        SELECT @IdCarga,
               IdDetalle,
               IdActividadPetrolera,
               ActividadPetrolera,
               IdSubactividadPetrolera,
               SubactividadPetrolera,
               IdTarea,
               Tarea,
               IdSubtarea,
               Subtarea_Servicio,
               Elegible,
               Area,
               Campo,
               Yacimiento,
               Pozo_Instalacion,
               CAPEX_OPEX,
               PA_17,
               PA_18,
               PA_19,
               PA_20,
               PA_21,
               PA_22,
               PA_23,
               PA_24,
               PA_25,
               PA_26,
               PA_27,
               PA_28,
               PA_29,
               PA_30,
               PA_31,
               PA_32,
               PA_33,
               PA_34,
               PA_35,
               PA_36,
               PA_37,
               PA_38,
               PA_39,
               PA_40,
               PA_41,
               PA_42,
               PA_43,
               PA_44,
               PA_45,
               PA_46,
               PA_47,
               PA_48,
               PA_49,
               PA_50,
               PA_51,
               PA_52,
               PA_53,
               PA_54,
               PA_55,
               PA_56,
               PA_57,
               PA_58,
               PA_59,
               PA_60,
               PA_61,
               PA_62,
               PA_63,
               PA_64,
               PA_65,
               PA_66,
               PA_67,
               PA_68,
               PA_69,
               PA_70,
               PA_71,
               PA_72,
               PA_73,
               PA_74,
               PA_75,
               PA_76,
               PA_77,
               PA_78,
               PA_79,
               PA_80,
               PA_81,
               PA_82,
               PA_83,
               PA_84,
               PA_85,
               PA_86,
               PA_87,
               PA_88,
               PA_89,
               PA_90,
               PA_91,
               PA_92,
               PA_93,
               PA_94,
               PA_95,
               PA_96,
               PA_97,
               PA_98,
               PA_99,
               PA_100,
               PA_101,
               PA_102,
               PA_103,
               PA_104,
               PA_105,
               PA_106,
               PA_107,
               PA_108,
               PA_109,
               PA_110,
               PA_111,
               PA_112,
               PA_113,
               PA_114,
               PA_115,
               PA_116,
               PA_117,
               PA_118,
               PA_119,
               PA_120,
               PA_121,
               PA_122,
               PA_123,
               PA_124,
               PA_125,
               PA_126,
               PA_127,
               PA_128,
               PA_129,
               PA_130,
               PA_131,
               PA_132,
               PA_133,
               PA_134,
               PA_135,
               PA_136,
               PA_137,
               PA_138,
               PA_139,
               PA_140,
               PA_141,
               PA_142,
               PA_143,
               PA_144,
               PA_145,
               PA_146,
               PA_147,
               PA_148,
               PA_149,
               PA_150,
               PA_151,
               PA_152,
               PA_153,
               PA_154,
               PA_155,
               PA_156,
               PA_157,
               PA_158,
               PA_159,
               PA_160,
               PA_161,
               PA_162,
               PA_163,
               PA_164,
               PA_165,
               PA_166,
               PA_167,
               PA_168,
               PA_169,
               PA_170,
               PA_171,
               PA_172,
               PA_173,
               PA_174,
               PA_175,
               PA_176,
               PA_177,
               PA_178,
               PA_179,
               PA_180,
               PA_181,
               PA_182,
               PA_183,
               PA_184,
               PA_185,
               PA_186,
               PA_187,
               PA_188,
               PA_189,
               PA_190,
               PA_191,
               PA_192,
               PA_193,
               PA_194,
               PA_195,
               PA_196,
               PA_197,
               PA_198,
               PA_199,
               PA_200,
               PA_201,
               PA_202,
               PA_203,
               PA_204,
               PA_205,
               PA_206,
               PA_207,
               PA_208,
               PA_209,
               PA_210,
               PA_211,
               PA_212,
               PA_213,
               PA_214,
               PA_215,
               PA_216,
               PA_217,
               PA_218,
               PA_219,
               PA_220,
               PA_221,
               PA_222,
               PA_223,
               PA_224,
               PA_225,
               PA_226,
               PA_227,
               PA_228,
               PA_229,
               PA_230,
               PA_231,
               PA_232,
               PA_233,
               PA_234,
               PA_235,
               PA_236,
               PA_237,
               PA_238,
               PA_239,
               PA_240,
               PA_241,
               PA_242,
               PA_243,
               PA_244,
               PA_245,
               PA_246,
               PA_247,
               PA_248,
               PA_249,
               PA_250,
               PA_251,
               PA_252,
               PA_253,
               PA_254,
               PA_255,
               PA_256,
               PA_257,
               PA_258,
               PA_259,
               PA_260,
               PA_261,
               PA_262,
               PA_263,
               PA_264,
               PA_265,
               PA_266,
               PA_267,
               PA_268,
               PA_269,
               PA_270,
               PA_271,
               PA_272,
               PA_273,
               PA_274,
               PA_275,
               PA_276,
               PA_277,
               PA_278,
               PA_279,
               PA_280,
               PA_281,
               PA_282,
               PA_283,
               PA_284,
               PA_285,
               PA_286,
               PA_287,
               PA_288,
               PA_289,
               PA_290,
               PA_291,
               PA_292,
               PA_293,
               PA_294,
               PA_295,
               PA_296,
               PA_297,
               PA_298,
               PA_299,
               PA_300,
               PA_301,
               PA_302,
               PA_303,
               PA_304
        FROM @Table_CO_Type_BitacoraPresupuestoDetalle;
		 IF (@AdjuntarClaveSubtarea = 1)
        BEGIN
		INSERT INTO #TablaTemporalValidacionServicio
        (
            IdSubtarea,
            Subtarea_Servicio,
            Existe,
            Activo,
            NumeroRepetidas
        )
        SELECT IdSubtarea,
               Subtarea_Servicio,
               0,
               0,
               COUNT(Subtarea_Servicio)
        FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
        WHERE IdCarga = @IdCarga
        GROUP BY IdSubtarea,
                 Subtarea_Servicio
		END
		ELSE
		BEGIN
		INSERT INTO #TablaTemporalValidacionServicio
        (
            IdSubtarea,
            Subtarea_Servicio,
            Existe,
            Activo,
            NumeroRepetidas
        )
        SELECT '',
               Subtarea_Servicio,
               0,
               0,
               COUNT(Subtarea_Servicio)
        FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
        WHERE IdCarga = @IdCarga
        GROUP BY Subtarea_Servicio
		END
        

        INSERT INTO #TablaTemporalValidacionInstalacion
        (
            Pozo_Instalacion,
            Existe,
            Activo,
            NumeroRepetidas
        )
        SELECT Pozo_Instalacion,
               0,
               0,
               COUNT(Pozo_Instalacion)
        FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
        WHERE IdCarga = @IdCarga
        GROUP BY Pozo_Instalacion

        IF (@AdjuntarClaveSubtarea = 1)
        BEGIN
            UPDATE #TablaTemporalValidacionServicio
            SET #TablaTemporalValidacionServicio.Activo = ISNULL(CO_Servicio.Activo, 0),
                #TablaTemporalValidacionServicio.Existe = 1
            FROM #TablaTemporalValidacionServicio
                JOIN CO_Servicio
                    ON LTRIM(RTRIM(CONCAT(
                                             #TablaTemporalValidacionServicio.IdSubtarea,
                                             '-',
                                             #TablaTemporalValidacionServicio.Subtarea_Servicio
                                         )
                                  )
                            ) = LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, '')))
            WHERE CO_Servicio.IdContrato = @IdContratoSeleccionado

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.IdSubtarea,
                                         '-',
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ') [NO ACTIVO]'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Activo = 0
                  AND Existe = 1
                  AND Subtarea_Servicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.IdSubtarea,
                                         '-',
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
										 ')'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Existe = 0
                  AND Subtarea_Servicio <> ''
        END
        ELSE
        BEGIN
            UPDATE #TablaTemporalValidacionServicio
            SET #TablaTemporalValidacionServicio.Activo = ISNULL(CO_Servicio.Activo, 0),
                #TablaTemporalValidacionServicio.Existe = 1
            FROM #TablaTemporalValidacionServicio
                JOIN CO_Servicio 
                    ON LTRIM(RTRIM(#TablaTemporalValidacionServicio.Subtarea_Servicio)) = LTRIM(RTRIM(ISNULL(
                                                                                                                CO_Servicio.NombreServicio,
                                                                                                                ''
                                                                                                            )
                                                                                                     )
                                                                                               )
            WHERE CO_Servicio.IdContrato = @IdContratoSeleccionado

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ') [NO ACTIVO]'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Activo = 0
                  AND Existe = 1
                  AND Subtarea_Servicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
										 ')'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Existe = 0
                  AND Subtarea_Servicio <> ''
        END

		INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         'Se encontraron un total de (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
										 ') filas con servicios vacíos'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE  ISNULL(Subtarea_Servicio, '') = ''

        UPDATE #TablaTemporalValidacionInstalacion
        SET #TablaTemporalValidacionInstalacion.Activo = ISNULL(CO_Instalacion.Activo, 0),
            #TablaTemporalValidacionInstalacion.Existe = 1
        FROM #TablaTemporalValidacionInstalacion
            JOIN CO_Instalacion
                ON LTRIM(RTRIM(#TablaTemporalValidacionInstalacion.Pozo_Instalacion)) = LTRIM(RTRIM(ISNULL(
                                                                                                              CO_Instalacion.NombreInstalacion,
                                                                                                              ''
                                                                                                          )
                                                                                                   )
                                                                                             )
        WHERE CO_Instalacion.IdAreaContractual = @IdAreaContractual

        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
									 #TablaTemporalValidacionInstalacion.Pozo_Instalacion,
									 ' (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ') [NO ACTIVO]'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE Activo = 0
              AND Existe = 1
              AND Pozo_Instalacion <> ''

        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
									 #TablaTemporalValidacionInstalacion.Pozo_Instalacion,
									 ' (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ')'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE Existe = 0
              AND Pozo_Instalacion <> ''


			  INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
									 'Se encontraron un total de  (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ') filas con instalaciones vacías'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE  ISNULL(Pozo_Instalacion, '') = '';

        SELECT @NumeroAlertasServicio = COUNT(1)
        FROM #TablaTemporalValidacionDetalles
        WHERE Tipo = 'ALERTA_SERVICIO'

        SELECT @NumeroAlertasInstalacion = COUNT(1)
        FROM #TablaTemporalValidacionDetalles
        WHERE Tipo = 'ALERTA_INSTALACION'

        IF (@NumeroAlertasServicio > 0 AND @NumeroAlertasInstalacion > 0)
            SELECT @Mensaje = 'ALERTA_SERVICIO_INSTALACION'
		IF (@NumeroAlertasServicio > 0 AND @NumeroAlertasInstalacion = 0)
            SELECT @Mensaje = 'ALERTA_SERVICIO'
       IF (@NumeroAlertasServicio = 0 AND @NumeroAlertasInstalacion > 0)
            SELECT @Mensaje = 'ALERTA_INSTALACION'
         IF (@NumeroAlertasServicio = 0 AND @NumeroAlertasInstalacion = 0)
            SELECT @Mensaje = 'VALIDACION_EXITOSA'

        SELECT @Mensaje AS MENSAJE

        IF (@Mensaje <> 'VALIDACION_EXITOSA')
        BEGIN
            SELECT Descripcion
            FROM #TablaTemporalValidacionDetalles
            WHERE Tipo = 'ALERTA_SERVICIO'

            SELECT Descripcion
            FROM #TablaTemporalValidacionDetalles
            WHERE Tipo = 'ALERTA_INSTALACION'

            IF (@NumeroAlertasServicio > 0)
            BEGIN
                IF (@NumeroAlertasServicio = 1)
                BEGIN
                    SELECT @DetalleAnalisis = CONCAT(@DetalleAnalisis, 'Existe nuevo servicio (', Descripcion, ') | ')
                    FROM #TablaTemporalValidacionDetalles
                    WHERE Tipo = 'ALERTA_SERVICIO'
                END
                ELSE
                BEGIN
                    SELECT @DetalleAnalisisServicios = STUFF(
                                                       (
                                                           SELECT ', ' + Descripcion
                                                           FROM #TablaTemporalValidacionDetalles
                                                           WHERE Tipo = 'ALERTA_SERVICIO'
                                                           FOR XML PATH('')
                                                       ),
                                                       1,
                                                       2,
                                                       ''
                                                            )

                    SELECT @DetalleAnalisis
                        = CONCAT(
                                    @DetalleAnalisis,
                                    'Existen ',
                                    CONVERT(VARCHAR(10), @NumeroAlertasServicio),
                                    ' nuevos servicios (',
                                    @DetalleAnalisisServicios,
                                    ') | '
                                );
                END
            END

            IF (@NumeroAlertasInstalacion > 0)
            BEGIN
                IF (@NumeroAlertasInstalacion = 1)
                BEGIN
                    SELECT @DetalleAnalisis
                        = CONCAT(@DetalleAnalisis, 'Existe nueva instalación (', Descripcion, ') | ')
                    FROM #TablaTemporalValidacionDetalles
                    WHERE Tipo = 'ALERTA_INSTALACION'
                END
                ELSE
                BEGIN
                    SELECT @DetalleAnalisisInstalaciones = STUFF(
                                                           (
                                                               SELECT ', ' + Descripcion
                                                               FROM #TablaTemporalValidacionDetalles
                                                               WHERE Tipo = 'ALERTA_INSTALACION'
                                                               FOR XML PATH('')
                                                           ),
                                                           1,
                                                           2,
                                                           ''
                                                                )

                    SELECT @DetalleAnalisis
                        = CONCAT(
                                    @DetalleAnalisis,
                                    'Existen ',
                                    CONVERT(VARCHAR(10), @NumeroAlertasInstalacion),
                                    ' nuevas instalaciones (',
                                    @DetalleAnalisisInstalaciones,
                                    ') | '
                                );
                END
            END

			SET @DetalleAnalisis =REPLACE(@DetalleAnalisis, '&amp;', '&');
            UPDATE CO_BitacoraPresupuesto
            SET DetalleAnalisis = LEFT(@DetalleAnalisis, LEN(@DetalleAnalisis) - 2)
            WHERE IdCarga = @Idcarga
        END
        ELSE
        BEGIN
            UPDATE CO_BitacoraPresupuesto
            SET DetalleAnalisis = 'Validación Exitosa'
            WHERE IdCarga = @Idcarga
        END

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END