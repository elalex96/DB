CREATE PROCEDURE FMR_Consulta50
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
    @val23 NVARCHAR(255),
    @val24 NVARCHAR(255),
    @val25 NVARCHAR(255),
    @val26 NVARCHAR(255),
    @val27 NVARCHAR(255),
    @val28 NVARCHAR(255),
    @val29 NVARCHAR(255),
    @val30 NVARCHAR(255),
    @val31 NVARCHAR(255),
    @val32 NVARCHAR(255),
    @val33 NVARCHAR(255),
    @val34 NVARCHAR(255),
    @val35 NVARCHAR(255),
    @val36 NVARCHAR(255),
    @val37 NVARCHAR(255),
    @val38 NVARCHAR(255),
    @val39 NVARCHAR(255),
    @val40 NVARCHAR(255),
    @val41 NVARCHAR(255),
    @val42 NVARCHAR(255),
    @val43 NVARCHAR(255),
    @val44 NVARCHAR(255),
    @val45 NVARCHAR(255),
    @val46 NVARCHAR(255),
    @val47 NVARCHAR(255),
    @val48 NVARCHAR(255),
    @val49 NVARCHAR(255),
    @val50 NVARCHAR(255),
    @val51 NVARCHAR(255),
    @val52 NVARCHAR(255),
    @val53 NVARCHAR(255),
    @val54 NVARCHAR(255),
    @val55 NVARCHAR(255),
    @val56 NVARCHAR(255),
    @val57 NVARCHAR(255),
    @val58 NVARCHAR(255),
    @val59 NVARCHAR(255),
    @val60 NVARCHAR(255),
    @val61 NVARCHAR(255),
    @IdUsuario INT,
    @idContrato INT,
    @nombreArchivo NVARCHAR(255)
AS
BEGIN
    DECLARE @CountIgual INT,
            @idcontratoArchivo INT,
            @idTipoArchivo INT;
    SELECT @CountIgual = COUNT([ID del contratista asignado por el SIPAC (RF_00)])
    FROM dbo.RML_FMP_50_M
    WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @val1
          AND [ID registro fiduciario del contrato (RI_00)] = @val2
          AND [ID del contrato asignado por CNH (RF01_01)] = @val3
          AND [Mes de reporte (RM50_00)] = @val4
          AND [Año de reporte (RM50_01)] = @val5
          AND [Producción: Volumen contractual de petróleo (RM50_02)] = @val6
          AND [Volumen contractual: producción de metano de gas natural asociad] = @val7
          AND [Producción: Volumen contractual de etano de gas natural asociado] = @val8
          AND [Producción: Volumen contractual de propano de gas natural asocia] = @val9
          AND [Producción: Volumen contractual de butano de gas natural asociad] = @val10
          AND [Producción: Volumen contractual de metano de gas natural no asoc] = @val11
          AND [Producción: Volumen contractual de etano de gas natural no asoci] = @val12
          AND [Producción: Volumen contractual de propano de gas natural no aso] = @val13
          AND [Producción: Volumen contractual de butano de gas natural no asoc] = @val14
          AND [Producción: Volumen contractual de condensados (RM50_11)] = @val15
          AND [Precio contractual: petróleo (RM50_12)] = @val16
          AND [Precio contractual: metano (RM50_13)] = @val17
          AND [Precio contractual: etano (RM50_14)] = @val18
          AND [Precio contractual: propano (RM50_15)] = @val19
          AND [Precio contractual: butano (RM50_16)] = @val20
          AND [Precio contractual: condensados (RM50_17)] = @val21
          AND [Tipo de precio que aplicó en la determinación del precio contrac] = @val22
          AND [Tipo de precio que aplicó en la determinación del precio contra1] = @val23
          AND [Tipo de precio que aplicó en la determinación del precio contra2] = @val24
          AND [Tipo de precio que aplicó en la determinación del precio contra3] = @val25
          AND [Tipo de precio que aplicó en la determinación del precio contra4] = @val26
          AND [Tipo de precio que aplicó en la determinación del precio contra5] = @val27
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?: ] = @val28
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:1] = @val29
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:2] = @val30
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:3] = @val31
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:4] = @val32
          AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:5] = @val33
          AND [Valor contractual: petróleo (RM50_30)] = @val34
          AND [Valor contractual: metano de gas natural asociado (RM50_31)] = @val35
          AND [Valor contractual: etano de gas natural asociado (RM50_32)] = @val36
          AND [Valor contractual: propano de gas natural asociado (RM50_33)] = @val37
          AND [Valor contractual: butano de gas natural asociado (RM50_34)] = @val38
          AND [Valor contractual: metano de gas natural no asociado (RM50_35)] = @val39
          AND [Valor contractual: etano de gas natural no asociado (RM50_36)] = @val40
          AND [Valor contractual: propano de gas natural no asociado (RM50_37)] = @val41
          AND [Valor contractual: butano de gas natural no asociado (RM50_38)] = @val42
          AND [Valor contractual: condensados (RM50_39)] = @val43
          AND [Total del valor contractual de los hidrocarburos (RM50_40)] = @val44
          AND [Tasa aplicable para el pago de la Regalía Base: petróleo (RM50_4] = @val45
          AND [Tasa aplicable para el pago de la Regalía Base: metano de gas na] = @val46
          AND [Tasa aplicable para el pago de la Regalía Base: etano de gas nat] = @val47
          AND [Tasa aplicable para el pago de la Regalía Base: propano de gas n] = @val48
          AND [Tasa aplicable para el pago de la Regalía Base: butano de gas na] = @val49
          AND [Tasa aplicable para el pago de la Regalía Base: metano de gas n1] = @val50
          AND [Tasa aplicable para el pago de la Regalía Base: etano de gas na1] = @val51
          AND [Tasa aplicable para el pago de la Regalía Base: propano de gas 1] = @val52
          AND [Tasa aplicable para el pago de la Regalía Base: butano de gas n1] = @val53
          AND [Tasa aplicable para el pago de la Regalía Base: condensados (RM5] = @val54
          AND [¿Se aplicó el mecanismo de ajuste? (RM50_51)] = @val55
          AND [Factor de ajuste para la determinación del monto de la contrapre] = @val56
          AND [Factor de ajuste para la determinación del monto de la contrapr1] = @val57
          AND [Tasa aplicable al valor contractual del petróleo y condensados e] = @val58
          AND [Tasa aplicable al valor contractual del gas natural en el period] = @val59;

    IF (@CountIgual > 0)
    BEGIN
        DELETE FROM dbo.RML_FMP_50_M
        WHERE [ID del contratista asignado por el SIPAC (RF_00)] = @val1
              AND [ID registro fiduciario del contrato (RI_00)] = @val2
              AND [ID del contrato asignado por CNH (RF01_01)] = @val3
              AND [Mes de reporte (RM50_00)] = @val4
              AND [Año de reporte (RM50_01)] = @val5
              AND [Producción: Volumen contractual de petróleo (RM50_02)] = @val6
              AND [Volumen contractual: producción de metano de gas natural asociad] = @val7
              AND [Producción: Volumen contractual de etano de gas natural asociado] = @val8
              AND [Producción: Volumen contractual de propano de gas natural asocia] = @val9
              AND [Producción: Volumen contractual de butano de gas natural asociad] = @val10
              AND [Producción: Volumen contractual de metano de gas natural no asoc] = @val11
              AND [Producción: Volumen contractual de etano de gas natural no asoci] = @val12
              AND [Producción: Volumen contractual de propano de gas natural no aso] = @val13
              AND [Producción: Volumen contractual de butano de gas natural no asoc] = @val14
              AND [Producción: Volumen contractual de condensados (RM50_11)] = @val15
              AND [Precio contractual: petróleo (RM50_12)] = @val16
              AND [Precio contractual: metano (RM50_13)] = @val17
              AND [Precio contractual: etano (RM50_14)] = @val18
              AND [Precio contractual: propano (RM50_15)] = @val19
              AND [Precio contractual: butano (RM50_16)] = @val20
              AND [Precio contractual: condensados (RM50_17)] = @val21
              AND [Tipo de precio que aplicó en la determinación del precio contrac] = @val22
              AND [Tipo de precio que aplicó en la determinación del precio contra1] = @val23
              AND [Tipo de precio que aplicó en la determinación del precio contra2] = @val24
              AND [Tipo de precio que aplicó en la determinación del precio contra3] = @val25
              AND [Tipo de precio que aplicó en la determinación del precio contra4] = @val26
              AND [Tipo de precio que aplicó en la determinación del precio contra5] = @val27
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?: ] = @val28
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:1] = @val29
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:2] = @val30
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:3] = @val31
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:4] = @val32
              AND [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:5] = @val33
              AND [Valor contractual: petróleo (RM50_30)] = @val34
              AND [Valor contractual: metano de gas natural asociado (RM50_31)] = @val35
              AND [Valor contractual: etano de gas natural asociado (RM50_32)] = @val36
              AND [Valor contractual: propano de gas natural asociado (RM50_33)] = @val37
              AND [Valor contractual: butano de gas natural asociado (RM50_34)] = @val38
              AND [Valor contractual: metano de gas natural no asociado (RM50_35)] = @val39
              AND [Valor contractual: etano de gas natural no asociado (RM50_36)] = @val40
              AND [Valor contractual: propano de gas natural no asociado (RM50_37)] = @val41
              AND [Valor contractual: butano de gas natural no asociado (RM50_38)] = @val42
              AND [Valor contractual: condensados (RM50_39)] = @val43
              AND [Total del valor contractual de los hidrocarburos (RM50_40)] = @val44
              AND [Tasa aplicable para el pago de la Regalía Base: petróleo (RM50_4] = @val45
              AND [Tasa aplicable para el pago de la Regalía Base: metano de gas na] = @val46
              AND [Tasa aplicable para el pago de la Regalía Base: etano de gas nat] = @val47
              AND [Tasa aplicable para el pago de la Regalía Base: propano de gas n] = @val48
              AND [Tasa aplicable para el pago de la Regalía Base: butano de gas na] = @val49
              AND [Tasa aplicable para el pago de la Regalía Base: metano de gas n1] = @val50
              AND [Tasa aplicable para el pago de la Regalía Base: etano de gas na1] = @val51
              AND [Tasa aplicable para el pago de la Regalía Base: propano de gas 1] = @val52
              AND [Tasa aplicable para el pago de la Regalía Base: butano de gas n1] = @val53
              AND [Tasa aplicable para el pago de la Regalía Base: condensados (RM5] = @val54
              AND [¿Se aplicó el mecanismo de ajuste? (RM50_51)] = @val55
              AND [Factor de ajuste para la determinación del monto de la contrapre] = @val56
              AND [Factor de ajuste para la determinación del monto de la contrapr1] = @val57
              AND [Tasa aplicable al valor contractual del petróleo y condensados e] = @val58
              AND [Tasa aplicable al valor contractual del gas natural en el period] = @val59;
    END;


    INSERT INTO dbo.RML_FMP_50_M ([ID del contratista asignado por el SIPAC (RF_00)],
                                  [ID registro fiduciario del contrato (RI_00)],
                                  [ID del contrato asignado por CNH (RF01_01)],
                                  [Mes de reporte (RM50_00)],
                                  [Año de reporte (RM50_01)],
                                  [Producción: Volumen contractual de petróleo (RM50_02)],
                                  [Volumen contractual: producción de metano de gas natural asociad],
                                  [Producción: Volumen contractual de etano de gas natural asociado],
                                  [Producción: Volumen contractual de propano de gas natural asocia],
                                  [Producción: Volumen contractual de butano de gas natural asociad],
                                  [Producción: Volumen contractual de metano de gas natural no asoc],
                                  [Producción: Volumen contractual de etano de gas natural no asoci],
                                  [Producción: Volumen contractual de propano de gas natural no aso],
                                  [Producción: Volumen contractual de butano de gas natural no asoc],
                                  [Producción: Volumen contractual de condensados (RM50_11)],
                                  [Precio contractual: petróleo (RM50_12)],
                                  [Precio contractual: metano (RM50_13)],
                                  [Precio contractual: etano (RM50_14)],
                                  [Precio contractual: propano (RM50_15)],
                                  [Precio contractual: butano (RM50_16)],
                                  [Precio contractual: condensados (RM50_17)],
                                  [Tipo de precio que aplicó en la determinación del precio contrac],
                                  [Tipo de precio que aplicó en la determinación del precio contra1],
                                  [Tipo de precio que aplicó en la determinación del precio contra2],
                                  [Tipo de precio que aplicó en la determinación del precio contra3],
                                  [Tipo de precio que aplicó en la determinación del precio contra4],
                                  [Tipo de precio que aplicó en la determinación del precio contra5],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?: ],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:1],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:2],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:3],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:4],
                                  [¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:5],
                                  [Valor contractual: petróleo (RM50_30)],
                                  [Valor contractual: metano de gas natural asociado (RM50_31)],
                                  [Valor contractual: etano de gas natural asociado (RM50_32)],
                                  [Valor contractual: propano de gas natural asociado (RM50_33)],
                                  [Valor contractual: butano de gas natural asociado (RM50_34)],
                                  [Valor contractual: metano de gas natural no asociado (RM50_35)],
                                  [Valor contractual: etano de gas natural no asociado (RM50_36)],
                                  [Valor contractual: propano de gas natural no asociado (RM50_37)],
                                  [Valor contractual: butano de gas natural no asociado (RM50_38)],
                                  [Valor contractual: condensados (RM50_39)],
                                  [Total del valor contractual de los hidrocarburos (RM50_40)],
                                  [Tasa aplicable para el pago de la Regalía Base: petróleo (RM50_4],
                                  [Tasa aplicable para el pago de la Regalía Base: metano de gas na],
                                  [Tasa aplicable para el pago de la Regalía Base: etano de gas nat],
                                  [Tasa aplicable para el pago de la Regalía Base: propano de gas n],
                                  [Tasa aplicable para el pago de la Regalía Base: butano de gas na],
                                  [Tasa aplicable para el pago de la Regalía Base: metano de gas n1],
                                  [Tasa aplicable para el pago de la Regalía Base: etano de gas na1],
                                  [Tasa aplicable para el pago de la Regalía Base: propano de gas 1],
                                  [Tasa aplicable para el pago de la Regalía Base: butano de gas n1],
                                  [Tasa aplicable para el pago de la Regalía Base: condensados (RM5],
                                  [¿Se aplicó el mecanismo de ajuste? (RM50_51)],
                                  [Factor de ajuste para la determinación del monto de la contrapre],
                                  [Factor de ajuste para la determinación del monto de la contrapr1],
                                  [Tasa aplicable al valor contractual del petróleo y condensados e],
                                  [Tasa aplicable al valor contractual del gas natural en el period],
                                  [Estado (activo)],
                                  [Fecha registro (fechaRegistro)])
    VALUES (@val1,  -- ID del contratista asignado por el SIPAC (RF_00) - nvarchar(255)
            @val2,  -- ID registro fiduciario del contrato (RI_00) - nvarchar(255)
            @val3,  -- ID del contrato asignado por CNH (RF01_01) - nvarchar(255)
            @val4,  -- Mes de reporte (RM50_00) - nvarchar(255)
            @val5,  -- Año de reporte (RM50_01) - nvarchar(255)
            @val6,  -- Producción: Volumen contractual de petróleo (RM50_02) - nvarchar(255)
            @val7,  -- Volumen contractual: producción de metano de gas natural asociad - nvarchar(255)
            @val8,  -- Producción: Volumen contractual de etano de gas natural asociado - nvarchar(255)
            @val9,  -- Producción: Volumen contractual de propano de gas natural asocia - nvarchar(255)
            @val10, -- Producción: Volumen contractual de butano de gas natural asociad - nvarchar(255)
            @val11, -- Producción: Volumen contractual de metano de gas natural no asoc - nvarchar(255)
            @val12, -- Producción: Volumen contractual de etano de gas natural no asoci - nvarchar(255)
            @val13, -- Producción: Volumen contractual de propano de gas natural no aso - nvarchar(255)
            @val14, -- Producción: Volumen contractual de butano de gas natural no asoc - nvarchar(255)
            @val15, -- Producción: Volumen contractual de condensados (RM50_11) - nvarchar(255)
            @val16, -- Precio contractual: petróleo (RM50_12) - nvarchar(255)
            @val17, -- Precio contractual: metano (RM50_13) - nvarchar(255)
            @val18, -- Precio contractual: etano (RM50_14) - nvarchar(255)
            @val19, -- Precio contractual: propano (RM50_15) - nvarchar(255)
            @val20, -- Precio contractual: butano (RM50_16) - nvarchar(255)
            @val21, -- Precio contractual: condensados (RM50_17) - nvarchar(255)
            @val22, -- Tipo de precio que aplicó en la determinación del precio contrac - nvarchar(255)
            @val23, -- Tipo de precio que aplicó en la determinación del precio contra1 - nvarchar(255)
            @val24, -- Tipo de precio que aplicó en la determinación del precio contra2 - nvarchar(255)
            @val25, -- Tipo de precio que aplicó en la determinación del precio contra3 - nvarchar(255)
            @val26, -- Tipo de precio que aplicó en la determinación del precio contra4 - nvarchar(255)
            @val27, -- Tipo de precio que aplicó en la determinación del precio contra5 - nvarchar(255)
            @val28, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:  - nvarchar(255)
            @val29, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:1 - nvarchar(255)
            @val30, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:2 - nvarchar(255)
            @val31, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:3 - nvarchar(255)
            @val32, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:4 - nvarchar(255)
            @val33, -- ¿Se aplicó ajuste por utilizar fórmula en periodos anteriores?:5 - nvarchar(255)
            @val34, -- Valor contractual: petróleo (RM50_30) - nvarchar(255)
            @val35, -- Valor contractual: metano de gas natural asociado (RM50_31) - nvarchar(255)
            @val36, -- Valor contractual: etano de gas natural asociado (RM50_32) - nvarchar(255)
            @val37, -- Valor contractual: propano de gas natural asociado (RM50_33) - nvarchar(255)
            @val38, -- Valor contractual: butano de gas natural asociado (RM50_34) - nvarchar(255)
            @val39, -- Valor contractual: metano de gas natural no asociado (RM50_35) - nvarchar(255)
            @val40, -- Valor contractual: etano de gas natural no asociado (RM50_36) - nvarchar(255)
            @val41, -- Valor contractual: propano de gas natural no asociado (RM50_37) - nvarchar(255)
            @val42, -- Valor contractual: butano de gas natural no asociado (RM50_38) - nvarchar(255)
            @val43, -- Valor contractual: condensados (RM50_39) - nvarchar(255)
            @val44, -- Total del valor contractual de los hidrocarburos (RM50_40) - nvarchar(255)
            @val45, -- Tasa aplicable para el pago de la Regalía Base: petróleo (RM50_4 - nvarchar(255)
            @val46, -- Tasa aplicable para el pago de la Regalía Base: metano de gas na - nvarchar(255)
            @val47, -- Tasa aplicable para el pago de la Regalía Base: etano de gas nat - nvarchar(255)
            @val48, -- Tasa aplicable para el pago de la Regalía Base: propano de gas n - nvarchar(255)
            @val49, -- Tasa aplicable para el pago de la Regalía Base: butano de gas na - nvarchar(255)
            @val50, -- Tasa aplicable para el pago de la Regalía Base: metano de gas n1 - nvarchar(255)
            @val51, -- Tasa aplicable para el pago de la Regalía Base: etano de gas na1 - nvarchar(255)
            @val52, -- Tasa aplicable para el pago de la Regalía Base: propano de gas 1 - nvarchar(255)
            @val53, -- Tasa aplicable para el pago de la Regalía Base: butano de gas n1 - nvarchar(255)
            @val54, -- Tasa aplicable para el pago de la Regalía Base: condensados (RM5 - nvarchar(255)
            @val55, -- ¿Se aplicó el mecanismo de ajuste? (RM50_51) - nvarchar(255)
            @val56, -- Factor de ajuste para la determinación del monto de la contrapre - nvarchar(255)
            @val57, -- Factor de ajuste para la determinación del monto de la contrapr1 - nvarchar(255)
            @val58, -- Tasa aplicable al valor contractual del petróleo y condensados e - nvarchar(255)
            @val59, -- Tasa aplicable al valor contractual del gas natural en el period - nvarchar(255)
            @val60, -- Estado (activo) - varchar(1500)
            @val61  -- Fecha registro (fechaRegistro) - varchar(1500)
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
    VALUES (@idTipoArchivo,             -- IdTipoReporte - int
            @nombreArchivo,             -- NombreArchivo - nvarchar(max)
            @val5 + '-' + @val4 + '-01', -- FechaReporte - date
            NULL,                       -- ReporteArchivo - image
            @IdUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEn - datetime
            @idcontratoArchivo          -- IdContrato - int
        );
    --	SELECT * FROM dbo.AA_ReportesCargados

    IF @@ERROR <> 0
        SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
    ELSE
        SELECT '' AS error;
END;

