CREATE PROCEDURE [dbo].[sp_HistorialAprobacionesScoc] --10061,10010
    @idUsuario  INT,
    @idContrato INT
AS
    BEGIN

        SET LANGUAGE spanish;

        IF OBJECT_ID('tempdb..#TempHistorialCalculos') IS NOT NULL
            DROP TABLE #TempHistorialCalculos;

        CREATE TABLE #TempHistorialCalculos
            (
                id          INT PRIMARY KEY IDENTITY(1, 1),
                MesReporte  VARCHAR(100),
                mes         DATE,
                AprobadoPor VARCHAR(200),
                AprobadoEl  VARCHAR(200),
                idContrato  INT
            );

        IF OBJECT_ID('tempdb..#TempHistorialCalculosComentario') IS NOT NULL
            DROP TABLE #TempHistorialCalculosComentario;

        CREATE TABLE #TempHistorialCalculosComentario
            (
                IDHistorialCalculo INT,
                id                 INT,
                MesReporte         VARCHAR(100),
                mes                DATE,
                AprobadoPor        VARCHAR(200),
                AprobadoEl         VARCHAR(200),
                idContrato         INT
            );

        INSERT INTO #TempHistorialCalculos
            (
                MesReporte,
                mes,
                AprobadoPor,
                AprobadoEl,
                idContrato
            )
                    (SELECT
                             DATENAME(MONTH, SCOC_EnvioNotificacion.MesReporte) + ' '
                             + LTRIM(YEAR(SCOC_EnvioNotificacion.MesReporte)) AS MesReporte,
                             SCOC_EnvioNotificacion.MesReporte                AS mes,
                             CASE IdTipoContrato
                                 WHEN 2
                                     THEN 
									 'Representante SCOC: '+dbo.AP_Usuario.Nombre
                                 ELSE
                                    'Representante PEP: '+ ap2.Nombre
                             END                                              AS AprobadoPor,
                             CASE IdTipoContrato
                                 WHEN 2
                                     THEN LTRIM(DAY(FechaAprobacion)) + ' ' + DATENAME(MONTH, FechaAprobacion) + ' '
                                          + LTRIM(YEAR(FechaAprobacion))
                                 ELSE
                                     LTRIM(DAY(FechaAprobacionRepPEP)) + ' ' + DATENAME(MONTH, FechaAprobacionRepPEP) + ' '
                                     + LTRIM(YEAR(FechaAprobacionRepPEP))
                             END                                              AS AprobadoEl,
                             SCOC_EnvioNotificacion.idContrato
                     FROM
                             SCOC_FormatoAmazon
                         JOIN
                             dbo.SCOC_EnvioNotificacion
                                 ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
                                    AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
                       left  JOIN
                             dbo.AP_Usuario
                                 ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoSCOC
                      left   JOIN
                             dbo.CO_Contrato
                                 ON CO_Contrato.IdContrato = SCOC_EnvioNotificacion.idContrato
                     left    JOIN
                             dbo.AP_Usuario AS ap2
                                 ON ap2.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
                     WHERE
                             SCOC_FormatoAmazon.idContrato = @idContrato
                             --AND AprobadoSCOC                  = 1
                             AND idestatus = 10005
                     GROUP BY
                             DATENAME(MONTH, SCOC_EnvioNotificacion.MesReporte) + ' '
                             + LTRIM(YEAR(SCOC_EnvioNotificacion.MesReporte)),
                             CASE IdTipoContrato
                                WHEN 2
                                     THEN 
									 'Representante SCOC: '+dbo.AP_Usuario.Nombre
                                 ELSE
                                    'Representante PEP: '+ ap2.Nombre
                             END,
                              CASE IdTipoContrato
                                 WHEN 2
                                     THEN LTRIM(DAY(FechaAprobacion)) + ' ' + DATENAME(MONTH, FechaAprobacion) + ' '
                                          + LTRIM(YEAR(FechaAprobacion))
                                 ELSE
                                     LTRIM(DAY(FechaAprobacionRepPEP)) + ' ' + DATENAME(MONTH, FechaAprobacionRepPEP) + ' '
                                     + LTRIM(YEAR(FechaAprobacionRepPEP))
                             END,
                             SCOC_EnvioNotificacion.idContrato,
                             SCOC_EnvioNotificacion.MesReporte);

        --SELECT * FROM #TempHistorialCalculosComentario
        INSERT INTO #TempHistorialCalculosComentario
            (
                IDHistorialCalculo,
                id,
                MesReporte,
                mes,
                AprobadoPor,
                AprobadoEl,
                idContrato
            )
                    (SELECT
                             MAX(idHistorialCalculo) IDHistorialCalculo,
                             t.id,
                             t.MesReporte,
                             t.mes,
                             t.AprobadoPor,
                             t.AprobadoEl,
                             t.idContrato
                     FROM
                             #TempHistorialCalculos                  t
                         LEFT JOIN
                             SCOC_HistorialAprobadosReiniciosCalculo H
                                 ON t.idContrato = H.idContrato
                                    AND t.MesReporte = H.MesReporte
                                    AND Accion = 'REINICIO DE PROCESO POR USUARIO SCOC'
                     GROUP BY
                             t.id,
                             t.MesReporte,
                             t.mes,
                             t.AprobadoPor,
                             t.AprobadoEl,
                             t.idContrato);

        SELECT
                T.MesReporte,
                T.mes,
                T.AprobadoPor,
                T.AprobadoEl,
                T.idContrato,
                ISNULL(
                          'Este calculo tuvo un reinició de flujo el día: ' + LTRIM(SHARC.CreadoEn)
                          + ', Comentario de reinició: "' + Comentarios + '"', ''
                      ) AS Comentario
        FROM
                #TempHistorialCalculosComentario        T
            LEFT JOIN
                SCOC_HistorialAprobadosReiniciosCalculo SHARC
                    ON T.IDHistorialCalculo = SHARC.idHistorialCalculo;

    END;

