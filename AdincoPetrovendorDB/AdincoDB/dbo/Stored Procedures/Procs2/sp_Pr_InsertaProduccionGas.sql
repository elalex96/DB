/****** Object:  StoredProcedure [dbo].[sp_Pr_InsertaProduccionGas]    Script Date: 07/02/2019 02:02:10 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180904
-- Description:	Inserta Produccion de Reporte diario
-- =============================================
CREATE PROCEDURE [dbo].[sp_Pr_InsertaProduccionGas]-- 10010,10061,'20180901','CNH-M1-EK-BALAM/2017','M3','15°','CampoPrueba','20180901','20180901',1,2.3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,'20180901','1'
    @IdContrato INT,
    @idUsuario INT,
    @Mes DATE,
    @Contrato NVARCHAR(MAX),
    @UnidadMedida NVARCHAR(MAX),
    @Temperatura NVARCHAR(MAX),
    @PuntoEntrega VARCHAR(MAX),
    @FechaReporte DATE,
    @FechaEntrega DATE,
    @Dia INT,
    @M3_20Grados FLOAT,
    @MMPC_NoAprov_20Grados FLOAT,
    @MMPC20BN FLOAT,
    @H2S FLOAT,
    @CO2 FLOAT,
    @N2 FLOAT,
    @C1 FLOAT,
    @C2 FLOAT,
    @C3 FLOAT,
    @IC4 FLOAT,
    @NC4 FLOAT,
    @IC5 FLOAT,
    @NC5 FLOAT,
    @C6 FLOAT,
    @C7 FLOAT,
    @C8 FLOAT,
    @C9 FLOAT,
    @C10 FLOAT,
    @PM FLOAT,
    @PoderCalBTU FLOAT,
    @DensidadRelativa FLOAT,
    @FechaCromatografia DATE,
	@CombustibleMTC FLOAT,
    @CombustibleEC FLOAT,
	@CombustibleCAB FLOAT,
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
        SELECT @IdContratista = IdContratista
        FROM dbo.CO_Contrato
        WHERE IdContrato = @IdContrato;

        SELECT @IdContratoArchivo = IdContrato
        FROM dbo.CO_Contrato
        WHERE NumeroContrato LIKE '%' + @Contrato + '%';

        SELECT @IdContratistaArchivo = IdContratista
        FROM dbo.CO_Contrato
        WHERE IdContrato = @IdContratoArchivo;

        SELECT @IdUnidadMedida = idUnidadMedida
        FROM dbo.CO_UnidadMedida
        WHERE Abreviatura = @UnidadMedida;
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

        IF (@IdContratista = @IdContratistaArchivo)
        BEGIN
            IF (@CountPuntosEntregaContrato > 0)
            BEGIN
					IF(@j=10)
					BEGIN 
					DELETE FROM SCOC_ReporteDiarioGas WHERE IdContrato=@IdContrato AND MesReporte=@Mes
					END;

                INSERT INTO SCOC_ReporteDiarioGas
                (
                    IdContrato,
                    MesReporte,
                    FechaReporte,
                    FechaEntrega,
                    Dia,
                    M3_20Grados,
                    Volumen15Grados,
                    MMPC_NoAprov_20Grados,
                    MMPC20BN,
                    H2S,
                    CO2,
                    N2,
                    C1,
                    C2,
                    C3,
                    IC4,
                    NC4,
                    IC5,
                   NC5,
                    C6,
                    C7,
                    C8,
                    C9,
                    C10,
                    PM,
                    PoderCalBTU,
                    DensidadRelativa,
                    FechaCromatografia,
                    IdUnidadMedida,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    CampoID,
					Temperatura,
					CombustibleMTC,
					CombustibleEC,
					CombustibleCAB
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
                                                                                       END, @MMPC_NoAprov_20Grados,
                    @MMPC20BN, @H2S, @CO2, @N2, @C1, @C2, @C3, @IC4, @NC4, @IC5, @NC5, @C6, @C7, @C8, @C9, @C10, @PM,
                    @PoderCalBTU, @DensidadRelativa, @FechaCromatografia, @IdUnidadMedida, @idUsuario, GETDATE(),
                    @idUsuario, GETDATE(), @CampoID, @Temp,@CombustibleMTC,@CombustibleEC,@CombustibleCAB);



            END;
            ELSE
            BEGIN
                SET @pError
                    = 'No se encuentra dado de alta el campo con el nombre:' + @PuntoEntrega
                      + ' de la hoja RD_GAS,linea ' + @j + ' ó No esta ligado al contrato:' + @Contrato
                      + ' en el sistema ADINCO';
                SELECT @pError AS error;
            END;

        END;
        ELSE
        BEGIN
            SET @pError
                = 'No puede ingresar informacion del contrato ' + @Contrato + ' en la hoja RD_GAS, linea ' + @j
                  + ',ya que no pertenece al mismo contratista';
            SELECT @pError AS error;
        END;

    END;
    ELSE
    BEGIN
        SET @pError
            = 'El mes elegido en la pantalla no es el mismo a la Fecha Reporte que tiene en la hoja RD_GAS, linea '
              + @j;
        SELECT @pError AS error;
    END;
END;
END;


