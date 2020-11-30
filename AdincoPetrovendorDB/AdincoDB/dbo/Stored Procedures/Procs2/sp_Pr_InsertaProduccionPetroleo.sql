/****** Object:  StoredProcedure [dbo].[sp_Pr_InsertaProduccionPetroleo]    Script Date: 07/02/2019 02:09:55 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180904
-- Description:	Inserta Produccion de Reporte diario
-- =============================================
CREATE PROCEDURE [dbo].[sp_Pr_InsertaProduccionPetroleo] -- 10010,10061,'20180901','CNH-M1-EK-BALAM/2017','MMPC','20°','EK','20180902','20180902',5,4668.18,18.50,7688.00,3.63,0.9404,0.9404,2

    @IdContrato INT,
    @idUsuario INT,
    @Mes DATE,
    @Contrato NVARCHAR(MAX),
    @UnidadMedida NVARCHAR(MAX),
    @Temperatura NVARCHAR(MAX),
    @PuntoEntrega NVARCHAR(MAX),
    @FechaReporte DATE,
    @FechaEntrega DATE,
    @Dia INT,
    @M3_20Grados FLOAT,
    @gradosApi FLOAT,
    @aguasedimento FLOAT,
    @sal FLOAT,
    @azufre FLOAT,
    @Peso_ESPEC FLOAT,
    @ComentarioContratista NVARCHAR(MAX),
    @ComentarioComercializador NVARCHAR(MAX),
    @j VARCHAR(15) --LINEA DEL EXCEL
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IdContratista INT,
            @IdContratistaArchivo INT,
            @IdContratoArchivo INT,
            @Count INT,
            @pError NVARCHAR(MAX) = '',
            @IdUnidadMedida INT,
			@CampoID INT,
            @CountPuntosEntregaContrato INT,
            @Temp FLOAT,
            @idProducto INT,
			@UltimoDia	INT;

-- SE VALIDA QUE SOLO SE GUARDE LA INFORMACIÓN HASTA EL ULTIMO DIA DEL MES
SELECT @UltimoDia = DATEPART(DAY,EOMONTH(@Mes))

IF @Dia <= @UltimoDia
BEGIN

    IF (
           MONTH(@Mes) = MONTH(@FechaReporte)
           AND YEAR(@Mes) = YEAR(@FechaReporte)
       )
    BEGIN
        SELECT @idProducto = ProductoNominacionID
        FROM CO_ClasificacionProductoNominacion
        WHERE NombreCNH = 'Petroleo';

        SELECT @Count = COUNT(*)
        FROM SCOC_ComentariosReportes
        WHERE IdContrato = @IdContrato
              AND MesReporte = @Mes
              AND ProductoNominacionID = @idProducto;
        IF (@Count = 0)
        BEGIN

            INSERT INTO SCOC_ComentariosReportes
            (
                IdContrato,
                MesReporte,
                ProductoNominacionID,
                ObservacionesContratista,
                ObservacionesComercializador,
                CreadoPor,
                CreadoEn,
                ModificadoPor,
                ModificadoEn
            )
            VALUES
            (@IdContrato, @Mes, @idProducto, @ComentarioContratista, @ComentarioComercializador, @idUsuario, GETDATE(),
             @idUsuario, GETDATE());
        END;
        ELSE
        BEGIN
            UPDATE SCOC_ComentariosReportes
            SET ObservacionesContratista = @ComentarioContratista,
                ObservacionesComercializador = @ComentarioComercializador,
                CreadoPor = @idUsuario,
                CreadoEn = GETDATE(),
                ModificadoPor = @idUsuario,
                ModificadoEn = GETDATE()
            WHERE IdContrato = @IdContrato
                  AND MesReporte = @Mes
                  AND ProductoNominacionID = @idProducto;
        END;

        SELECT @IdContratista = IdContratista
        FROM dbo.CO_Contrato
        WHERE IdContrato = @IdContrato;

        SELECT @IdContratoArchivo = IdContrato
        FROM dbo.CO_Contrato
        WHERE NumeroContrato LIKE '%' + @Contrato + '%';

        SELECT @IdContratistaArchivo = IdContratista
        FROM dbo.CO_Contrato
        WHERE IdContrato = @IdContratoArchivo;

        IF @UnidadMedida = 'Barril'
           OR @UnidadMedida = 'Barriles'
        BEGIN
            SET @UnidadMedida = 'BL';
        END;
        ------------------------------------------------------------
        IF @Temperatura = '20°'
        BEGIN
            SET @Temp = 20;
        END;
        IF @Temperatura = '15.56°'
        BEGIN
            SET @Temp = 15.56;
        END;

   
            SELECT @CampoID = C.CampoID
        FROM dbo.SCOC_Campo C
        WHERE LTRIM(RTRIM(NombreCampo)) = LTRIM(RTRIM(@PuntoEntrega));

      SELECT @CountPuntosEntregaContrato = COUNT(*)
        FROM SCOC_CampoContrato CC
            JOIN SCOC_Campo C
                ON C.CampoID = CC.CampoID
        WHERE CC.CampoID = @CampoID
              AND CC.IdContrato = @IdContrato
              AND CC.Bit_Activo = 1
              AND C.Activo = 1;
        -------------------------------------------------------------
        SELECT @IdUnidadMedida = idUnidadMedida
        FROM dbo.CO_UnidadMedida
        WHERE Abreviatura = @UnidadMedida;

        IF (@IdContratista = @IdContratistaArchivo)
        BEGIN

            IF (@CountPuntosEntregaContrato >= 1)
            BEGIN
                IF (@j = 10)
                BEGIN
                    DELETE FROM dbo.SCOC_ReporteDiarioPetroleo
                    WHERE IdContrato = @IdContrato
                          AND MesReporte = @Mes;
                END;

                INSERT INTO SCOC_ReporteDiarioPetroleo
                (
                    IdContrato,
                    MesReporte,
                    FechaReporte,
                    FechaEntrega,
                    Dia,
                    M3_20Grados,
                    Volumen15Grados,
                    GradosAPI,
                    AguaSedimento,
                    Sal,
                    Azufre,
                    PesoEspec,
                    IdUnidadMedida,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    CampoID,
                    Temperatura
                )
                VALUES
                (   @IdContratoArchivo, @Mes, @FechaReporte, @FechaEntrega, @Dia, CASE @Temp
                                                                                      WHEN 20 THEN
                                                                                          @M3_20Grados
                                                                                      ELSE
                                                                                          NULL
                                                                                  END, CASE @Temp
                                                                                           WHEN 15.56 THEN
                                                                                               @M3_20Grados
                                                                                           ELSE
                                                                                               NULL
                                                                                       END, @gradosApi, @aguasedimento,
                    @sal, @azufre, @Peso_ESPEC, @IdUnidadMedida, @idUsuario, GETDATE(), @idUsuario, GETDATE(),
                    @CampoID, @Temp);
            END;
            ELSE
            BEGIN
                SET @pError
                    = 'No se encuentra dado de alta el campo con el nombre:' + @PuntoEntrega
                      + ' de la hoja RD_CRUDO,linea ' + @j + ' ó No esta ligado al contrato:' + @Contrato
                      + ' en el sistema ADINCO';
                SELECT @pError AS error;
            END;

        END;
        ELSE
        BEGIN
            SET @pError
                = 'No puede ingresar informacion del contrato ' + @Contrato + ' en la hoja RD_CRUDO,linea ' + @j
                  + ', ya que no pertenece al mismo contratista';

            SELECT @pError AS error;
        END;


    END;
    ELSE
    BEGIN
        SET @pError
            = 'El mes elegido en la pantalla no es el mismo a la Fecha Reporte que tiene en la hoja RD_CRUDO, linea '
              + @j;
        SELECT @pError AS error;
    END;

END;

END;
