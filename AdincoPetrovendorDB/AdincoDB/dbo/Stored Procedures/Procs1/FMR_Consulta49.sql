CREATE PROCEDURE FMR_Consulta49
    @va1 NVARCHAR(250),
    @va2 NVARCHAR(250),
    @va3 NVARCHAR(250),
    @va4 NVARCHAR(250),
    @va5 NVARCHAR(250),
    @va6 NVARCHAR(250),
    @va7 NVARCHAR(250),
    @va8 NVARCHAR(250),
    @va9 NVARCHAR(250),
    @va10 NVARCHAR(250),
    @va11 NVARCHAR(250),
    @va12 NVARCHAR(250),
    @va13 NVARCHAR(250),
    @va14 NVARCHAR(250),
    @va15 NVARCHAR(250),
    @va16 NVARCHAR(250),
    @IdUsuario INT,
    @idContrato INT,
    @nombreArchivo NVARCHAR(255)
AS
BEGIN
    DECLARE @CountIgual INT,
            @idcontratoArchivo INT,
            @idTipoArchivo INT;

    SELECT @CountIgual = COUNT([ID del contratista asignado por el SIPAC (RF_00)])
    FROM dbo.RM_FMP_49_M
    WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @va1
          AND [ID registro fiduciario del contrato (RI_00)] = @va2
          AND [ID del contrato asignado por la CNH (RI_01)] = @va3
          AND [Mes de reporte (RM49_01)] = @va4
          AND [Año de reporte (RM49_02)] = @va5
          AND [Regalía Base: Regalía calculada por el FMP (RM49_03)] = @va6
          AND [Regalía Adicional: Regalía calculada por el FMP (RM49_04)] = @va7
          AND [Monto de la Cuota Exploratoria determinado por el FMP (RM49_05)] = @va8
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: petróleo (RM49_06)] = @va9
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: metano (RM49_07)] = @va10
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: etano (RM49_08)] = @va11
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: propano (RM49_09)] = @va12
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: butano (RM49_10)] = @va13
          AND [Transmisión Onerosa de los Hidrocarburos al Contratista: condensados (RM49_11)] = @va14;

    IF (@CountIgual > 0)
    BEGIN
        DELETE FROM dbo.RM_FMP_49_M
        WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @va1
              AND [ID registro fiduciario del contrato (RI_00)] = @va2
              AND [ID del contrato asignado por la CNH (RI_01)] = @va3
              AND [Mes de reporte (RM49_01)] = @va4
              AND [Año de reporte (RM49_02)] = @va5
              AND [Regalía Base: Regalía calculada por el FMP (RM49_03)] = @va6
              AND [Regalía Adicional: Regalía calculada por el FMP (RM49_04)] = @va7
              AND [Monto de la Cuota Exploratoria determinado por el FMP (RM49_05)] = @va8
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: petróleo (RM49_06)] = @va9
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: metano (RM49_07)] = @va10
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: etano (RM49_08)] = @va11
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: propano (RM49_09)] = @va12
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: butano (RM49_10)] = @va13
              AND [Transmisión Onerosa de los Hidrocarburos al Contratista: condensados (RM49_11)] = @va14;
    END;

    INSERT INTO dbo.RM_FMP_49_M ([ID del contratista asignado por el SIPAC (RF_00)],
                                 [ID registro fiduciario del contrato (RI_00)],
                                 [ID del contrato asignado por la CNH (RI_01)],
                                 [Mes de reporte (RM49_01)],
                                 [Año de reporte (RM49_02)],
                                 [Regalía Base: Regalía calculada por el FMP (RM49_03)],
                                 [Regalía Adicional: Regalía calculada por el FMP (RM49_04)],
                                 [Monto de la Cuota Exploratoria determinado por el FMP (RM49_05)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: petróleo (RM49_06)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: metano (RM49_07)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: etano (RM49_08)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: propano (RM49_09)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: butano (RM49_10)],
                                 [Transmisión Onerosa de los Hidrocarburos al Contratista: condensados (RM49_11)])
    VALUES (@va1,  -- ID del contratista asignado por el SIPAC (RF_00) - nvarchar(510)
            @va2,  -- ID registro fiduciario del contrato (RI_00) - nvarchar(510)
            @va3,  -- ID del contrato asignado por la CNH (RI_01) - nvarchar(510)
            @va4,  -- Mes de reporte (RM49_01) - nvarchar(250)
            @va5,  -- Año de reporte (RM49_02) - int
            @va6,  -- Regalía Base: Regalía calculada por el FMP (RM49_03) - nvarchar(255)
            @va7,  -- Regalía Adicional: Regalía calculada por el FMP (RM49_04) - nvarchar(255)
            @va8,  -- Monto de la Cuota Exploratoria determinado por el FMP (RM49_05) - nvarchar(255)
            @va9,  -- Transmisión Onerosa de los Hidrocarburos al Contratista: petróleo (RM49_06) - nvarchar(255)
            @va10, -- Transmisión Onerosa de los Hidrocarburos al Contratista: metano (RM49_07) - nvarchar(255)
            @va11, -- Transmisión Onerosa de los Hidrocarburos al Contratista: etano (RM49_08) - nvarchar(255)
            @va12, -- Transmisión Onerosa de los Hidrocarburos al Contratista: propano (RM49_09) - nvarchar(255)
            @va13, -- Transmisión Onerosa de los Hidrocarburos al Contratista: butano (RM49_10) - nvarchar(255)
            @va14  -- Transmisión Onerosa de los Hidrocarburos al Contratista: condensados (RM49_11) - nvarchar(255)
        );

    SELECT @idcontratoArchivo = IdContrato
    FROM dbo.CO_Contrato
    WHERE NumeroContrato = @va3;
    SELECT @idTipoArchivo = IdTipoReporte
    FROM dbo.AA_TipoReporte
    WHERE NombreReporte = @nombreArchivo;

    DELETE AA_ReportesCargados
    WHERE IdTipoReporte = IdTipoReporte
          AND IdContrato = @idcontratoArchivo
          AND FechaReporte = @va5 + '-' + @va4 + '-01';

    INSERT INTO dbo.AA_ReportesCargados (IdTipoReporte,
                                         NombreArchivo,
                                         FechaReporte,
                                         ReporteArchivo,
                                         CreadoPor,
                                         CreadoEn,
                                         IdContrato)
    VALUES (@idTipoArchivo,            -- IdTipoReporte - int
            @nombreArchivo,            -- NombreArchivo - nvarchar(max)
            @va5 + '-' + @va4 + '-01', -- FechaReporte - date
            NULL,                      -- ReporteArchivo - image
            @IdUsuario,                -- CreadoPor - int
            GETDATE(),                 -- CreadoEn - datetime
            @idcontratoArchivo         -- IdContrato - int
        );
    --	SELECT * FROM dbo.AA_ReportesCargados

    IF @@ERROR <> 0
        SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
    ELSE
        SELECT '' AS error;

END;

