CREATE PROCEDURE FMR_Consulta51
    @val1 NVARCHAR(255),
    @val2 NVARCHAR(255),
    @val3 NVARCHAR(255),
    @val4 NVARCHAR(255),
    @val5 NVARCHAR(255),
    @val6 NVARCHAR(255),
    @val7 NVARCHAR(255),
    @val8 NVARCHAR(255),
    @val9 NVARCHAR(255),
    @val10 NVARCHAR(255),
    @val11 NVARCHAR(255),
    @val12 NVARCHAR(255),
    @val13 NVARCHAR(255),
    @val14 NVARCHAR(255),
    @val15 NVARCHAR(255),
    @val16 NVARCHAR(255),
    @val17 NVARCHAR(255),
    @val18 NVARCHAR(255),
    @val19 NVARCHAR(255),
    @val20 NVARCHAR(255),
    @val21 NVARCHAR(255),
    @val22 NVARCHAR(255),
    @IdUsuario INT,
    @idContrato INT,
    @nombreArchivo NVARCHAR(255)
AS
BEGIN
    DECLARE @CountIgual INT,
            @idcontratoArchivo INT,
            @idTipoArchivo INT;
    SELECT @CountIgual = COUNT([ID del contratista asignado por el SIPAC (RF_00)])
    FROM dbo.RM_FMP_51_M
    WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @val1
          AND [ID registro fiduciario del contrato (RI_00)] = @val2
          AND [ID del contrato asignado por la CNH (RI_01)] = @val3
          AND [Mes de reporte (RM51_01)] = @val4
          AND [Año de reporte (RM51_02)] = @val5
          AND [Regalía Base: Saldo a favor del contratista de periodos anteriores (RM51_03)] = @val6
          AND [Regalía Base: Saldo a favor del contratista al cierre del 17 natural (RM51_04)] = @val7
          AND [Regalía Base: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_05)	] = @val8
          AND [Regalía Base: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_06)] = @val9
          AND [Regalía Base: Nuevo saldo a favor del contratista (RM51_07)] = @val10
          AND [Regalía Adicional: Saldo a favor del contratista de periodos anteriores (RM51_08)] = @val11
          AND [Regalía Adicional: Saldo a favor del contratista al cierre del 17 natural (RM51_09)] = @val12
          AND [Regalía Adicional: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_10)] = @val13
          AND [Regalía Adicional: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_11)] = @val14
          AND [Regalía Adicional: Nuevo saldo a favor del contratista (RM51_12)] = @val15
          AND [Cuota Exploratoria: Saldo a favor del contratista de periodos anteriores (RM51_13)] = @val16
          AND [Cuota Exploratoria: Saldo a favor del contratista al cierre del 17 natural (RM51_14)] = @val17
          AND [Cuota Exploratoria: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_15)] = @val18
          AND [Cuota Exploratoria: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_16)] = @val19
          AND [Cuota Exploratoria: Nuevo saldo a favor del contratista (RM51_17)] = @val20;
    IF (@CountIgual > 0)
    BEGIN
        DELETE FROM dbo.RM_FMP_51_M
        WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @val1
              AND [ID registro fiduciario del contrato (RI_00)] = @val2
              AND [ID del contrato asignado por la CNH (RI_01)] = @val3
              AND [Mes de reporte (RM51_01)] = @val4
              AND [Año de reporte (RM51_02)] = @val5
              AND [Regalía Base: Saldo a favor del contratista de periodos anteriores (RM51_03)] = @val6
              AND [Regalía Base: Saldo a favor del contratista al cierre del 17 natural (RM51_04)] = @val7
              AND [Regalía Base: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_05)	] = @val8
              AND [Regalía Base: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_06)] = @val9
              AND [Regalía Base: Nuevo saldo a favor del contratista (RM51_07)] = @val10
              AND [Regalía Adicional: Saldo a favor del contratista de periodos anteriores (RM51_08)] = @val11
              AND [Regalía Adicional: Saldo a favor del contratista al cierre del 17 natural (RM51_09)] = @val12
              AND [Regalía Adicional: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_10)] = @val13
              AND [Regalía Adicional: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_11)] = @val14
              AND [Regalía Adicional: Nuevo saldo a favor del contratista (RM51_12)] = @val15
              AND [Cuota Exploratoria: Saldo a favor del contratista de periodos anteriores (RM51_13)] = @val16
              AND [Cuota Exploratoria: Saldo a favor del contratista al cierre del 17 natural (RM51_14)] = @val17
              AND [Cuota Exploratoria: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_15)] = @val18
              AND [Cuota Exploratoria: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_16)] = @val19
              AND [Cuota Exploratoria: Nuevo saldo a favor del contratista (RM51_17)] = @val20;
    END;

    INSERT INTO dbo.RM_FMP_51_M ([ID del contratista asignado por el SIPAC (RF_00)],
                                 [ID registro fiduciario del contrato (RI_00)],
                                 [ID del contrato asignado por la CNH (RI_01)],
                                 [Mes de reporte (RM51_01)],
                                 [Año de reporte (RM51_02)],
                                 [Regalía Base: Saldo a favor del contratista de periodos anteriores (RM51_03)],
                                 [Regalía Base: Saldo a favor del contratista al cierre del 17 natural (RM51_04)],
                                 [Regalía Base: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_05)	],
                                 [Regalía Base: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_06)],
                                 [Regalía Base: Nuevo saldo a favor del contratista (RM51_07)],
                                 [Regalía Adicional: Saldo a favor del contratista de periodos anteriores (RM51_08)],
                                 [Regalía Adicional: Saldo a favor del contratista al cierre del 17 natural (RM51_09)],
                                 [Regalía Adicional: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_10)],
                                 [Regalía Adicional: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_11)],
                                 [Regalía Adicional: Nuevo saldo a favor del contratista (RM51_12)],
                                 [Cuota Exploratoria: Saldo a favor del contratista de periodos anteriores (RM51_13)],
                                 [Cuota Exploratoria: Saldo a favor del contratista al cierre del 17 natural (RM51_14)],
                                 [Cuota Exploratoria: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_15)],
                                 [Cuota Exploratoria: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_16)],
                                 [Cuota Exploratoria: Nuevo saldo a favor del contratista (RM51_17)])
    VALUES (@val1,  -- ID del contratista asignado por el SIPAC (RF_00) - nvarchar(510)
            @val2,  -- ID registro fiduciario del contrato (RI_00) - nvarchar(510)
            @val3,  -- ID del contrato asignado por la CNH (RI_01) - nvarchar(510)
            @val4,  -- Mes de reporte (RM51_01) - nvarchar(150)
            @val5,  -- Año de reporte (RM51_02) - int
            @val6,  -- Regalía Base: Saldo a favor del contratista de periodos anteriores (RM51_03) - nvarchar(510)
            @val7,  -- Regalía Base: Saldo a favor del contratista al cierre del 17 natural (RM51_04) - nvarchar(510)
            @val8,  -- Regalía Base: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_05)	 - nvarchar(510)
            @val9,  -- Regalía Base: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_06) - nvarchar(510)
            @val10, -- Regalía Base: Nuevo saldo a favor del contratista (RM51_07) - nvarchar(510)
            @val11, -- Regalía Adicional: Saldo a favor del contratista de periodos anteriores (RM51_08) - nvarchar(510)
            @val12, -- Regalía Adicional: Saldo a favor del contratista al cierre del 17 natural (RM51_09) - nvarchar(510)
            @val13, -- Regalía Adicional: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_10) - nvarchar(510)
            @val14, -- Regalía Adicional: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_11) - nvarchar(510)
            @val15, -- Regalía Adicional: Nuevo saldo a favor del contratista (RM51_12) - nvarchar(510)
            @val16, -- Cuota Exploratoria: Saldo a favor del contratista de periodos anteriores (RM51_13) - nvarchar(510)
            @val17, -- Cuota Exploratoria: Saldo a favor del contratista al cierre del 17 natural (RM51_14) - nvarchar(510)
            @val18, -- Cuota Exploratoria: Saldo a favor del contratista al cierre del periodo de ajustes (RM51_15) - nvarchar(510)
            @val19, -- Cuota Exploratoria: Saldo a favor del contratista posterior al cierre del periodo de ajustes (RM51_16) - nvarchar(510)
            @val20  -- Cuota Exploratoria: Nuevo saldo a favor del contratista (RM51_17) - nvarchar(510)
        );

    SELECT @idcontratoArchivo = IdContrato
    FROM dbo.CO_Contrato
    WHERE NumeroContrato = @val3;
    SELECT @idTipoArchivo = IdTipoReporte
    FROM dbo.AA_TipoReporte
    WHERE NombreReporte = @nombreArchivo;

    DELETE AA_ReportesCargados
    WHERE IdTipoReporte = IdTipoReporte
          AND IdContrato = @idcontratoArchivo
          AND FechaReporte = @val5 + '-' + @val4 + '-01';

    INSERT INTO dbo.AA_ReportesCargados (IdTipoReporte,
                                         NombreArchivo,
                                         FechaReporte,
                                         ReporteArchivo,
                                         CreadoPor,
                                         CreadoEn,
                                         IdContrato)
    VALUES (@idTipoArchivo,              -- IdTipoReporte - int
            @nombreArchivo,              -- NombreArchivo - nvarchar(max)
            @val5 + '-' + @val4 + '-01', -- FechaReporte - date
            NULL,                        -- ReporteArchivo - image
            @IdUsuario,                  -- CreadoPor - int
            GETDATE(),                   -- CreadoEn - datetime
            @idcontratoArchivo           -- IdContrato - int
        );
    --	SELECT * FROM dbo.AA_ReportesCargados

    IF @@ERROR <> 0
        SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
    ELSE
        SELECT '' AS error;

END;

