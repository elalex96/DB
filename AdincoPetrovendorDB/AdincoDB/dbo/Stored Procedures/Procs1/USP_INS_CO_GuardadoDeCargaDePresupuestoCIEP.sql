IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_ValidacionGuardadoDeCargaDePresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuestoCIEP;
GO
CREATE PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuestoCIEP
    @UsuarioId                                    INT,
    @ContratoId                                   INT,
    @IdArchivoAWS                                 INT,
    @IdContratoSeleccionado                       INT,
    @FechaInicio                                  DATE,
    @FechaFin                                     DATE,
    @Programa                                     VARCHAR(100),
    @Presupuesto                                  VARCHAR(100),
    @Periodo                                      VARCHAR(100),
    @AdjuntarClaveSubtarea                        BIT                                    = 0,
    @Table_CO_Type_BitacoraPresupuestoDetalleCIEP CO_Type_BitacoraPresupuestoDetalleCIEP READONLY,
    @IdTipoProgramaActividad                      INT,
    @Tipo                                         VARCHAR(100)
AS
    BEGIN
        BEGIN TRY
            BEGIN TRAN

            SET NOCOUNT ON;

            CREATE TABLE #TablaTemporalValidacionTipoServicio
                (
                    NombreTipoServicio  VARCHAR(1000) NULL,
                    IdTipoServicioTabla INT           NULL,
                    NumeroRepetidas     INT           NULL,
                    Activo              BIT           NULL
                )

            CREATE TABLE #TablaTemporalValidacionActividadCIEP
                (
                    NombreActividad VARCHAR(1000) NULL,
                    IdActividad     INT           NULL,
                    NumeroRepetidas INT           NULL
                )

            CREATE TABLE #TablaTemporalValidacionServicioCIEP
                (
                    NombreServicio  VARCHAR(1000) NULL,
                    IdServicio      INT           NULL,
                    NumeroRepetidas INT           NULL,
                    Activo          BIT           NULL
                )

            CREATE TABLE #TablaTemporalValidacionRubroCIEP
                (
                    NombreRubro     VARCHAR(1000) NULL,
                    IdRubro         INT           NULL,
                    NumeroRepetidas INT           NULL,
                    Activo          BIT           NULL
                )

            CREATE TABLE #TablaTemporalValidacionClasificacionCIEP
                (
                    NombreClasificacion VARCHAR(1000) NULL,
                    IdClasificacion     INT           NULL,
                    NumeroRepetidas     INT           NULL
                )

            CREATE TABLE #TablaTemporalValidacionDetalles
                (
                    Tipo                  VARCHAR(1000) NULL,
                    Descripcion           VARCHAR(1000) NULL,
                    TipoDetalle           VARCHAR(100)  NULL,
                    NombreDetallePantalla VARCHAR(100)  NULL,
                    MultiplesDetalles     BIT           NULL,
                    NumeroDeDetalles      INT           NULL
                )

            CREATE TABLE #TablaTemporalBitacoraPresupuestoDetalleCIEP
                (
                    IdExcel         int,
                    CuentaOperativa VARCHAR(1000),
                    Actividad       VARCHAR(1000),
                    Rubro           VARCHAR(1000),
                    Servicios       VARCHAR(1000),
                    Clasificacion   VARCHAR(1000),
                    Unidad          VARCHAR(1000),
                    MES1            FLOAT,
                    MES2            FLOAT,
                    MES3            FLOAT,
                    MES4            FLOAT,
                    MES5            FLOAT,
                    MES6            FLOAT,
                    MES7            FLOAT,
                    MES8            FLOAT,
                    MES9            FLOAT,
                    MES10           FLOAT,
                    MES11           FLOAT,
                    MES12           FLOAT,
                    MES13           FLOAT,
                    MES14           FLOAT,
                    MES15           FLOAT,
                    MES16           FLOAT,
                    MES17           FLOAT,
                    MES18           FLOAT,
                    MES19           FLOAT,
                    MES20           FLOAT,
                    MES21           FLOAT,
                    MES22           FLOAT,
                    MES23           FLOAT,
                    MES24           FLOAT,
                    Monto           FLOAT,
                    NumeroRenglon   INT NULL
                );

            DECLARE
                @ErrorMessage                       VARCHAR(4000),
                @DetalleAnalisis                    VARCHAR(8000),
                @DetalleAnalisisServicios           VARCHAR(8000),
                @DetalleAnalisisCuentaOperativa      VARCHAR(8000),
				@DetalleAnalisisActividad      VARCHAR(8000),
				@DetalleAnalisisRubro     VARCHAR(8000),
				@DetalleAnalisisClasificacion    VARCHAR(8000),
                @DetalleAnalisisDatosGenerales      VARCHAR(8000),
                @IdCarga                            INT         = 0,
                @IdAreaContractual                  INT         = 0,
                @NumeroAlertasDatosGenerales        INT         = 0,
                @NumeroAlertasCuentaOperativa       INT         = 0,
                @NumeroAlertasActividad             INT         = 0,
                @NumeroAlertasServicio              INT         = 0,
                @NumeroAlertasRubro                 INT         = 0,
                @NumeroAlertasClasificacion         INT         = 0,
                @Mensaje                            VARCHAR(50) = '',
                @NumeroAlertasCuentaOperativaVacios INT         = 0,
                @NumeroAlertasActividadVacios       INT         = 0,
                @NumeroAlertasServicioVacios        INT         = 0,
                @NumeroAlertasRubroVacios           INT         = 0,
                @NumeroAlertasClasificacionVacios   INT         = 0;

            SELECT TOP 1
                @IdAreaContractual = IdAreaContractual
            FROM
                CO_Contrato (NOLOCK)
            WHERE
                IdContrato = @IdContratoSeleccionado

            INSERT INTO CO_BitacoraPresupuesto
                (
                    IdArchivoAWS,
                    IdContrato,
                    Inicio,
                    Fin,
                    CreadoEl,
                    CreadoPor,
                    chkAdjuntaClaveSubTarea,
                    IdTipoProgramaActividad,
                    Programa,
                    Presupuesto,
                    Periodo,
                    Tipo
                )
            VALUES
                (
                    @IdArchivoAWS,
                    @IdContratoSeleccionado,
                    @FechaInicio,
                    @FechaFin,
                    GETDATE(),
                    @UsuarioId,
                    @AdjuntarClaveSubtarea,
                    @IdTipoProgramaActividad,
                    @Programa,
                    @Presupuesto,
                    @Periodo,
                    @Tipo
                )

            SELECT
                @IdCarga = SCOPE_IDENTITY();

            INSERT INTO CO_BitacoraPresupuestoDetalleCIEP
                (
                    IdCarga,
                    IdExcel,
                    CuentaOperativa,
                    Actividad,
                    Rubro,
                    Servicios,
                    Clasificacion,
                    Unidad,
                    MES1,
                    MES2,
                    MES3,
                    MES4,
                    MES5,
                    MES6,
                    MES7,
                    MES8,
                    MES9,
                    MES10,
                    MES11,
                    MES12,
                    MES13,
                    MES14,
                    MES15,
                    MES16,
                    MES17,
                    MES18,
                    MES19,
                    MES20,
                    MES21,
                    MES22,
                    MES23,
                    MES24
                )
                        SELECT
                            @IdCarga,
                            IdExcel,
                            CuentaOperativa,
                            Actividad,
                            Rubro,
                            Servicios,
                            Clasificacion,
                            Unidad,
                            MES1,
                            MES2,
                            MES3,
                            MES4,
                            MES5,
                            MES6,
                            MES7,
                            MES8,
                            MES9,
                            MES10,
                            MES11,
                            MES12,
                            MES13,
                            MES14,
                            MES15,
                            MES16,
                            MES17,
                            MES18,
                            MES19,
                            MES20,
                            MES21,
                            MES22,
                            MES23,
                            MES24
                        FROM
                            @Table_CO_Type_BitacoraPresupuestoDetalleCIEP;

            INSERT INTO #TablaTemporalBitacoraPresupuestoDetalleCIEP
                (
                    IdExcel,
                    CuentaOperativa,
                    Actividad,
                    Rubro,
                    Servicios,
                    Clasificacion,
                    Unidad,
                    MES1,
                    MES2,
                    MES3,
                    MES4,
                    MES5,
                    MES6,
                    MES7,
                    MES8,
                    MES9,
                    MES10,
                    MES11,
                    MES12,
                    MES13,
                    MES14,
                    MES15,
                    MES16,
                    MES17,
                    MES18,
                    MES19,
                    MES20,
                    MES21,
                    MES22,
                    MES23,
                    MES24,
                    Monto,
                    NumeroRenglon
                )
                        SELECT
                            IdExcel,
                            CuentaOperativa,
                            Actividad,
                            Rubro,
                            Servicios,
                            Clasificacion,
                            Unidad,
                            MES1,
                            MES2,
                            MES3,
                            MES4,
                            MES5,
                            MES6,
                            MES7,
                            MES8,
                            MES9,
                            MES10,
                            MES11,
                            MES12,
                            MES13,
                            MES14,
                            MES15,
                            MES16,
                            MES17,
                            MES18,
                            MES19,
                            MES20,
                            MES21,
                            MES22,
                            MES23,
                            MES24,
                            (ISNULL(MES1, 0) + ISNULL(MES2, 0) + ISNULL(MES3, 0) + ISNULL(MES4, 0) + ISNULL(MES5, 0)
                             + ISNULL(MES6, 0) + ISNULL(MES7, 0) + ISNULL(MES8, 0) + ISNULL(MES9, 0) + ISNULL(MES10, 0)
                             + ISNULL(MES11, 0) + ISNULL(MES12, 0) + ISNULL(MES13, 0) + ISNULL(MES14, 0)
                             + ISNULL(MES15, 0) + ISNULL(MES16, 0) + ISNULL(MES17, 0) + ISNULL(MES18, 0)
                             + ISNULL(MES19, 0) + ISNULL(MES20, 0) + ISNULL(MES21, 0) + ISNULL(MES22, 0)
                             + ISNULL(MES23, 0) + ISNULL(MES24, 0)
                            ),
                            NumeroRenglon
                        FROM
                            @Table_CO_Type_BitacoraPresupuestoDetalleCIEP;

            INSERT INTO #TablaTemporalValidacionTipoServicio
                (
                    NombreTipoServicio,
                    NumeroRepetidas
                )
                        SELECT
                            CuentaOperativa,
                            COUNT(1)
                        FROM
                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                        GROUP BY
                            CuentaOperativa;

            INSERT INTO #TablaTemporalValidacionActividadCIEP
                (
                    NombreActividad,
                    NumeroRepetidas
                )
                        SELECT
                            Actividad,
                            COUNT(1)
                        FROM
                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                        GROUP BY
                            Actividad;

            INSERT INTO #TablaTemporalValidacionServicioCIEP
                (
                    NombreServicio,
                    NumeroRepetidas
                )
                        SELECT
                            Servicios,
                            COUNT(1)
                        FROM
                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                        GROUP BY
                            Servicios;

            INSERT INTO #TablaTemporalValidacionRubroCIEP
                (
                    NombreRubro,
                    NumeroRepetidas
                )
                        SELECT
                            Rubro,
                            COUNT(1)
                        FROM
                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                        GROUP BY
                            Rubro;

            INSERT INTO #TablaTemporalValidacionClasificacionCIEP
                (
                    NombreClasificacion,
                    NumeroRepetidas
                )
                        SELECT
                            Clasificacion,
                            COUNT(1)
                        FROM
                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                        GROUP BY
                            Clasificacion;

            UPDATE
                #TablaTemporalValidacionTipoServicio
            SET
                #TablaTemporalValidacionTipoServicio.IdTipoServicioTabla = CO_TipoServicio.IdTipoServicio,
                #TablaTemporalValidacionTipoServicio.Activo = CO_TipoServicio.Activo
            from
                #TablaTemporalValidacionTipoServicio
                JOIN
                    CO_TipoServicio
                        ON UPPER(LTRIM(RTRIM(ISNULL(#TablaTemporalValidacionTipoServicio.NombreTipoServicio, '')))) = 
						   UPPER(LTRIM(RTRIM(ISNULL(CO_TipoServicio.NombreTipoServicio, ''))))
            WHERE
                #TablaTemporalValidacionTipoServicio.NombreTipoServicio <> '';

            UPDATE
                #TablaTemporalValidacionActividadCIEP
            SET
                #TablaTemporalValidacionActividadCIEP.IdActividad = CO_ActividadCIEP.IdActividad
            from
                #TablaTemporalValidacionActividadCIEP
                JOIN
                    CO_ActividadCIEP
                        ON UPPER(LTRIM(RTRIM(ISNULL(#TablaTemporalValidacionActividadCIEP.NombreActividad, '')))) = 
						   UPPER(LTRIM(RTRIM(ISNULL(CO_ActividadCIEP.NombreActividad, ''))))
						   AND CO_ActividadCIEP.IdContrato = @IdContratoSeleccionado
            WHERE
                #TablaTemporalValidacionActividadCIEP.NombreActividad <> '';

            UPDATE
                #TablaTemporalValidacionServicioCIEP
            SET
                #TablaTemporalValidacionServicioCIEP.IdServicio = CO_Servicio.IdServicio,
                #TablaTemporalValidacionServicioCIEP.Activo = CO_Servicio.Activo,
				#TablaTemporalValidacionServicioCIEP.NombreServicio = #TablaTemporalValidacionServicioCIEP.NombreServicio
            from
                #TablaTemporalValidacionServicioCIEP
                JOIN
                    CO_Servicio
                        ON UPPER(LTRIM(RTRIM(ISNULL(#TablaTemporalValidacionServicioCIEP.NombreServicio, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))))
            WHERE
                CO_Servicio.IdContrato = @IdContratoSeleccionado
                AND #TablaTemporalValidacionServicioCIEP.NombreServicio <> '';

            UPDATE
                #TablaTemporalValidacionRubroCIEP
            SET
                #TablaTemporalValidacionRubroCIEP.IdRubro = CO_Rubro.IdRubro,
                #TablaTemporalValidacionRubroCIEP.Activo = CO_Rubro.Activo
            from
                #TablaTemporalValidacionRubroCIEP
                JOIN
                    CO_Rubro
                        ON UPPER(LTRIM(RTRIM(ISNULL(#TablaTemporalValidacionRubroCIEP.NombreRubro, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_Rubro.NombreRubro, ''))))
            WHERE
                #TablaTemporalValidacionRubroCIEP.NombreRubro <> '';

            UPDATE
                #TablaTemporalValidacionClasificacionCIEP
            SET
                #TablaTemporalValidacionClasificacionCIEP.IdClasificacion = CO_Clasificacion.IdClasificacion
            from
                #TablaTemporalValidacionClasificacionCIEP
                JOIN
                    CO_Clasificacion
                        ON UPPER(LTRIM(RTRIM(ISNULL(#TablaTemporalValidacionClasificacionCIEP.NombreClasificacion, '')))) = UPPER(LTRIM(RTRIM(ISNULL(CO_Clasificacion.NombreClasificacion, ''))))
            WHERE
                #TablaTemporalValidacionClasificacionCIEP.NombreClasificacion <> '';


            /*=========================*/
            /*Verificacion de CO_TipoServicio*/
            /*=========================*/

            SELECT
                @NumeroAlertasCuentaOperativaVacios = COUNT(1)
            FROM
                #TablaTemporalBitacoraPresupuestoDetalleCIEP
            WHERE
                ISNULL(CuentaOperativa, '') = ''

            IF (@NumeroAlertasCuentaOperativaVacios > 0)
                BEGIN
                    IF (@NumeroAlertasCuentaOperativaVacios = 1)
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'CuentaOperativa',
                                            'Cuenta Operativa',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(CuentaOperativa, '') = ''
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(CuentaOperativa, '') = ''
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'CuentaOperativa',
                                    'Cuenta Operativa',
                                    1,
                                    @NumeroAlertasCuentaOperativaVacios
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                        END
                END


            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_CUENTA_OPERATIVA',
                            LTRIM(RTRIM(CONCAT(
                                                  NombreTipoServicio, ' (', CONVERT(VARCHAR(10), NumeroRepetidas),
                                                  ') [NO ACTIVO]'
                                              )
                                       )
                                 )
                        FROM
                            #TablaTemporalValidacionTipoServicio
                        WHERE
                            Activo = 0
                            AND IdTipoServicioTabla IS NOT NULL
                            AND NombreTipoServicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_CUENTA_OPERATIVA',
                            LTRIM(RTRIM(CONCAT(NombreTipoServicio, ' (', CONVERT(VARCHAR(10), NumeroRepetidas), ')')))
                        FROM
                            #TablaTemporalValidacionTipoServicio
                        WHERE
                            IdTipoServicioTabla IS NULL
                            AND NombreTipoServicio <> ''

            /*=========================*/
            /*Verificacion de CO_Servicio*/
            /*=========================*/

            SELECT
                @NumeroAlertasServicioVacios = COUNT(1)
            FROM
                #TablaTemporalBitacoraPresupuestoDetalleCIEP
            WHERE
                ISNULL(Servicios, '') = ''

            IF (@NumeroAlertasServicioVacios > 0)
                BEGIN
                    IF (@NumeroAlertasServicioVacios = 1)
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'Servicios',
                                            'Servicio',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(Servicios, '') = ''
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(Servicios, '') = ''
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'Servicios',
                                    'Servicio',
                                    1,
                                    @NumeroAlertasServicioVacios
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                        END
                END


            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_SERVICIO',
                            LTRIM(RTRIM(CONCAT(
                                                  NombreServicio, ' (', CONVERT(VARCHAR(10), NumeroRepetidas),
                                                  ') [NO ACTIVO]'
                                              )
                                       )
                                 )
                        FROM
                            #TablaTemporalValidacionServicioCIEP
                        WHERE
                            Activo = 0
                            AND IdServicio IS NOT NULL
                            AND NombreServicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_SERVICIO',
                            LTRIM(RTRIM(CONCAT(NombreServicio, ' (', CONVERT(VARCHAR(10), NumeroRepetidas), ') ')))
                        FROM
                            #TablaTemporalValidacionServicioCIEP
                        WHERE
                            IdServicio IS NULL
                            AND NombreServicio <> ''

            /*=========================*/
            /*Verificacion de CO_ActividadCIEP */
            /*=========================*/

            SELECT
                @NumeroAlertasActividadVacios = COUNT(1)
            FROM
                #TablaTemporalBitacoraPresupuestoDetalleCIEP
            WHERE
                ISNULL(Actividad, '') = ''

            IF (@NumeroAlertasActividadVacios > 0)
                BEGIN
                    IF (@NumeroAlertasActividadVacios = 1)
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'Actividades',
                                            'Actividad',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(Actividad, '') = ''
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(Actividad, '') = ''
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'Actividades',
                                    'Actividad',
                                    1,
                                    @NumeroAlertasActividadVacios
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                        END
                END


            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_ACTIVIDAD',
                            LTRIM(RTRIM(CONCAT(NombreActividad, ' (', CONVERT(VARCHAR(10), NumeroRepetidas), ') ')))
                        FROM
                            #TablaTemporalValidacionActividadCIEP
                        WHERE
                            IdActividad IS NULL
                            AND NombreActividad <> ''

            /*=========================*/
            /*Verificacion de CO_Rubro*/
            /*=========================*/
            SELECT
                @NumeroAlertasRubroVacios = COUNT(1)
            FROM
                #TablaTemporalBitacoraPresupuestoDetalleCIEP
            WHERE
                ISNULL(Rubro, '') = ''

            IF (@NumeroAlertasRubroVacios > 0)
                BEGIN
                    IF (@NumeroAlertasRubroVacios = 1)
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'Rubros',
                                            'Rubro',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(Rubro, '') = ''
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(Rubro, '') = ''
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'Rubros',
                                    'Rubro',
                                    1,
                                    @NumeroAlertasActividadVacios
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                        END
                END

            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_RUBRO',
                            LTRIM(RTRIM(CONCAT(
                                                  NombreRubro, ' (', CONVERT(VARCHAR(10), NumeroRepetidas),
                                                  ') [NO ACTIVO]'
                                              )
                                       )
                                 )
                        FROM
                            #TablaTemporalValidacionRubroCIEP
                        WHERE
                            Activo = 0
                            AND IdRubro IS NOT NULL
                            AND NombreRubro <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_RUBRO',
                            LTRIM(RTRIM(CONCAT(NombreRubro, ' (', CONVERT(VARCHAR(10), NumeroRepetidas), ') ')))
                        FROM
                            #TablaTemporalValidacionRubroCIEP
                        WHERE
                            IdRubro IS NULL
                            AND NombreRubro <> ''

            /*=========================*/
            /*Verificacion de CO_Clasificacion */
            /*=========================*/

            SELECT
                @NumeroAlertasClasificacionVacios = COUNT(1)
            FROM
                #TablaTemporalBitacoraPresupuestoDetalleCIEP
            WHERE
                ISNULL(Clasificacion, '') = ''

            IF (@NumeroAlertasClasificacionVacios > 0)
                BEGIN
                    IF (@NumeroAlertasClasificacionVacios = 1)
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'Clasificaciones',
                                            'Clasificacion',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(Clasificacion, '') = ''
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(Clasificacion, '') = ''
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'Clasificaciones',
                                    'Clasificacion',
                                    1,
                                    @NumeroAlertasClasificacionVacios
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                        END
                END

            INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion
                )
                        SELECT
                            'ALERTA_CLASIFICACION',
                            LTRIM(RTRIM(CONCAT(NombreClasificacion, ' (', CONVERT(VARCHAR(10), NumeroRepetidas), ') ')))
                        FROM
                            #TablaTemporalValidacionClasificacionCIEP
                        WHERE
                            IdClasificacion IS NULL
                            AND NombreClasificacion <> ''

            /*===========================*/
            /*Verificacion de Monto = 0*/
            /*===========================*/
            IF (
                   (
                       SELECT
                           COUNT(1)
                       FROM
                           #TablaTemporalBitacoraPresupuestoDetalleCIEP
                       WHERE
                           ISNULL(MONTO, 0) = 0
                   ) > 0
               )
                BEGIN
                    IF (
                           (
                               SELECT
                                   COUNT(1)
                               FROM
                                   #TablaTemporalBitacoraPresupuestoDetalleCIEP
                               WHERE
                                   ISNULL(MONTO, 0) = 0
                           ) = 1
                       )
                        BEGIN
                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                                        SELECT
                                            'ALERTA_DATOSGENERALES',
                                            CONCAT(
                                                      'Renglón: ',
                                                      CONVERT(
                                                                 VARCHAR(10),
                                                                 #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                             )
                                                  ),
                                            'MONTO',
                                            'Monto Presupuestado',
                                            0,
                                            1
                                        FROM
                                            #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                        WHERE
                                            ISNULL(MONTO, 0) = 0
                                        ORDER BY
                                            IdExcel ASC
                        END
                    ELSE
                        BEGIN
                            SELECT
                                @DetalleAnalisisDatosGenerales
                                = CONCAT(
                                            'Renglones: ',
                                            STUFF(
                                                (
                                                    SELECT
                                                        ', '
                                                        + CONVERT(
                                                                     VARCHAR(10),
                                                                     #TablaTemporalBitacoraPresupuestoDetalleCIEP.NumeroRenglon
                                                                 )
                                                    FROM
                                                        #TablaTemporalBitacoraPresupuestoDetalleCIEP
                                                    WHERE
                                                        ISNULL(MONTO, 0) = 0
                                                    ORDER BY
                                                        IdExcel ASC
                                                    FOR XML PATH('')
                                                ), 1, 2, ''
                                                 )
                                        )

                            SELECT
                                @NumeroAlertasDatosGenerales = COUNT(1)
                            FROM
                                #TablaTemporalBitacoraPresupuestoDetalleCIEP
                            WHERE
                                ISNULL(MONTO, 0) = 0;

                            INSERT INTO #TablaTemporalValidacionDetalles
                                (
                                    Tipo,
                                    Descripcion,
                                    TipoDetalle,
                                    NombreDetallePantalla,
                                    MultiplesDetalles,
                                    NumeroDeDetalles
                                )
                            VALUES
                                (
                                    'ALERTA_DATOSGENERALES',
                                    @DetalleAnalisisDatosGenerales,
                                    'MONTO',
                                    'Monto Presupuestado',
                                    1,
                                    @NumeroAlertasDatosGenerales
                                )

                            SET @DetalleAnalisisDatosGenerales = '';
                            SET @NumeroAlertasDatosGenerales = 0;
                        END
                END

            /*===========================*/
            /*RETORNO DE MENSAJES A PANTALLA*/
            /*===========================*/

            SELECT
                @NumeroAlertasDatosGenerales = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_DATOSGENERALES';

            SELECT
                @NumeroAlertasCuentaOperativa = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_CUENTA_OPERATIVA';

            SELECT
                @NumeroAlertasActividad = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_ACTIVIDAD';

            SELECT
                @NumeroAlertasServicio = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_SERVICIO';

            SELECT
                @NumeroAlertasRubro = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_RUBRO';

            SELECT
                @NumeroAlertasClasificacion = COUNT(1)
            FROM
                #TablaTemporalValidacionDetalles
            WHERE
                Tipo = 'ALERTA_CLASIFICACION';

            IF (
                   @NumeroAlertasDatosGenerales = 0
                   AND @NumeroAlertasCuentaOperativa = 0
                   AND @NumeroAlertasActividad = 0
                   AND @NumeroAlertasServicio = 0
                   AND @NumeroAlertasRubro = 0
                   AND @NumeroAlertasClasificacion = 0
               )
                SELECT
                    @Mensaje = 'VALIDACION_EXITOSA';

            IF (
                   @NumeroAlertasDatosGenerales > 0
                   AND @NumeroAlertasCuentaOperativa > 0
                   AND @NumeroAlertasActividad > 0
                   AND @NumeroAlertasServicio > 0
                   AND @NumeroAlertasRubro > 0
                   AND @NumeroAlertasClasificacion > 0
               )
                SELECT
                    @Mensaje = 'ALERTA_TODAS_ALERTAS'

            SELECT
                @Mensaje AS MENSAJE; -- 0


            IF (@Mensaje <> 'VALIDACION_EXITOSA')
                BEGIN
                    SELECT
                        Descripcion
                    FROM
                        #TablaTemporalValidacionDetalles -- 1
                    WHERE
                        Tipo = 'ALERTA_SERVICIO';

                    SELECT
                        Descripcion
                    FROM
                        #TablaTemporalValidacionDetalles -- 2
                    WHERE
                        Tipo = 'ALERTA_CUENTA_OPERATIVA'

                    SELECT
                        Descripcion,
                        TipoDetalle,
                        NumeroDeDetalles,
                        NombreDetallePantalla
                    FROM
                        #TablaTemporalValidacionDetalles -- 3 
                    WHERE
                        Tipo = 'ALERTA_DATOSGENERALES';

                    SELECT
                        Descripcion
                    FROM
                        #TablaTemporalValidacionDetalles -- 4
                    WHERE
                        Tipo = 'ALERTA_ACTIVIDAD'


                    SELECT
                        Descripcion
                    FROM
                        #TablaTemporalValidacionDetalles -- 5
                    WHERE
                        Tipo = 'ALERTA_RUBRO';

                    SELECT
                        Descripcion
                    FROM
                        #TablaTemporalValidacionDetalles -- 6
                    WHERE
                        Tipo = 'ALERTA_CLASIFICACION';

                    IF (@NumeroAlertasServicio > 0)
                        BEGIN
                            SELECT
                                @DetalleAnalisisServicios = STUFF(
                                                                (
                                                                    SELECT
                                                                        ', ' + Descripcion
                                                                    FROM
                                                                        #TablaTemporalValidacionDetalles
                                                                    WHERE
                                                                        Tipo = 'ALERTA_SERVICIO'
                                                                    FOR XML PATH('')
                                                                ), 1, 2, ''
                                                                 );

                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            (CASE
                                                 WHEN @NumeroAlertasServicio > 1
                                                     THEN 'Existen ' + CONVERT(VARCHAR(10), @NumeroAlertasServicio)
                                                          + ' nuevos servicios ( ' + @DetalleAnalisisServicios + ' )	|'
                                                 ELSE
                                                     'Existe ' + CONVERT(VARCHAR(10), @NumeroAlertasServicio)
                                                     + ' nuevo servicio ( ' + @DetalleAnalisisServicios + ' )	|'
                                             END
                                            )
                                        );
                            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                        END

					 IF (@NumeroAlertasCuentaOperativa > 0)
                        BEGIN
                            SELECT
                                @DetalleAnalisisCuentaOperativa = STUFF(
                                                                (
                                                                    SELECT
                                                                        ', ' + Descripcion
                                                                    FROM
                                                                        #TablaTemporalValidacionDetalles
                                                                    WHERE
                                                                        Tipo = 'ALERTA_CUENTA_OPERATIVA'
                                                                    FOR XML PATH('')
                                                                ), 1, 2, ''
                                                                 );

                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            (CASE
                                                 WHEN @NumeroAlertasCuentaOperativa > 1
                                                     THEN 'Existen ' + CONVERT(VARCHAR(10), @NumeroAlertasCuentaOperativa)
                                                          + ' nuevas cuentas operativas ( ' + @DetalleAnalisisCuentaOperativa + ' )	|'
                                                 ELSE
                                                     'Existe ' + CONVERT(VARCHAR(10), @NumeroAlertasCuentaOperativa)
                                                     + ' nueva cuenta operativa ( ' + @DetalleAnalisisCuentaOperativa + ' )	|'
                                             END
                                            )
                                        );
                            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                        END

					IF (@NumeroAlertasActividad > 0)
                        BEGIN
                            SELECT
                                @DetalleAnalisisActividad = STUFF(
                                                                (
                                                                    SELECT
                                                                        ', ' + Descripcion
                                                                    FROM
                                                                        #TablaTemporalValidacionDetalles
                                                                    WHERE
                                                                        Tipo = 'ALERTA_ACTIVIDAD'
                                                                    FOR XML PATH('')
                                                                ), 1, 2, ''
                                                                 );

                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            (CASE
                                                 WHEN @NumeroAlertasActividad > 1
                                                     THEN 'Existen ' + CONVERT(VARCHAR(10), @NumeroAlertasActividad)
                                                          + ' nuevas actividades ( ' + @DetalleAnalisisActividad + ' )	|'
                                                 ELSE
                                                     'Existe ' + CONVERT(VARCHAR(10), @NumeroAlertasActividad)
                                                     + ' nueva actividad ( ' + @DetalleAnalisisActividad + ' )	|'
                                             END
                                            )
                                        );
                            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                        END

					IF (@NumeroAlertasRubro > 0)
                        BEGIN
                            SELECT
                                @DetalleAnalisisRubro = STUFF(
                                                                (
                                                                    SELECT
                                                                        ', ' + Descripcion
                                                                    FROM
                                                                        #TablaTemporalValidacionDetalles
                                                                    WHERE
                                                                        Tipo = 'ALERTA_RUBRO'
                                                                    FOR XML PATH('')
                                                                ), 1, 2, ''
                                                                 );

                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            (CASE
                                                 WHEN @NumeroAlertasRubro > 1
                                                     THEN 'Existen ' + CONVERT(VARCHAR(10), @NumeroAlertasRubro)
                                                          + ' nuevos rubros ( ' + @DetalleAnalisisRubro + ' )	|'
                                                 ELSE
                                                     'Existe ' + CONVERT(VARCHAR(10), @NumeroAlertasRubro)
                                                     + ' nuevo rubro ( ' + @DetalleAnalisisRubro + ' )	|'
                                             END
                                            )
                                        );
                            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                        END

					IF (@NumeroAlertasClasificacion > 0)
                        BEGIN
                            SELECT
                                @DetalleAnalisisClasificacion = STUFF(
                                                                (
                                                                    SELECT
                                                                        ', ' + Descripcion
                                                                    FROM
                                                                        #TablaTemporalValidacionDetalles
                                                                    WHERE
                                                                        Tipo = 'ALERTA_CLASIFICACION'
                                                                    FOR XML PATH('')
                                                                ), 1, 2, ''
                                                                 );

                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            (CASE
                                                 WHEN @NumeroAlertasClasificacion > 1
                                                     THEN 'Existen ' + CONVERT(VARCHAR(10), @NumeroAlertasClasificacion)
                                                          + ' nuevas clasificaciones ( ' + @DetalleAnalisisClasificacion + ' )	|'
                                                 ELSE
                                                     'Existe ' + CONVERT(VARCHAR(10), @NumeroAlertasClasificacion)
                                                     + ' nueva clasificación ( ' + @DetalleAnalisisClasificacion + ' )	|'
                                             END
                                            )
                                        );
                            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                        END

                    IF (@NumeroAlertasDatosGenerales > 0)
                        BEGIN

                            -- Seleccionar y concatenar los resultados de múltiples tipos de detalle en un solo paso
                            SELECT
                                @DetalleAnalisis
                                = CONCAT(
                                            @DetalleAnalisis,
                                            CASE
                                                WHEN MultiplesDetalles = 0
                                                    THEN 'Existe un registro sin ' + NombreDetallePantalla + ' en '
                                                         + ISNULL(Descripcion, '') + ' | '
                                                WHEN MultiplesDetalles = 1
                                                    THEN 'Existen (' + CONVERT(VARCHAR(10), NumeroDeDetalles)
                                                         + ') registros sin ' + NombreDetallePantalla + ' en '
                                                         + ISNULL(Descripcion, '') + ' | '
                                            END
                                        )
                            FROM
                                #TablaTemporalValidacionDetalles
                            WHERE
                                Tipo = 'ALERTA_DATOSGENERALES'
                            group by
                                TipoDetalle,
                                MultiplesDetalles,
                                NombreDetallePantalla,
                                Descripcion,
                                NumeroDeDetalles

                        END

                    SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

                    UPDATE
                        CO_BitacoraPresupuesto
                    SET
                        DetalleAnalisis = LEFT(@DetalleAnalisis, LEN(@DetalleAnalisis) - 2)
                    WHERE
                        IdCarga = @Idcarga
                END
            ELSE
                BEGIN
                    UPDATE
                        CO_BitacoraPresupuesto
                    SET
                        DetalleAnalisis = 'Validación Exitosa'
                    WHERE
                        IdCarga = @Idcarga
                END

            COMMIT TRAN
        END TRY
        BEGIN CATCH
            SELECT
                @ErrorMessage = ERROR_MESSAGE()

            ROLLBACK TRAN

            RAISERROR(@ErrorMessage, 17, 1)
        END CATCH;
    END