-- =============================================
-- Author:		Manuel CD
-- Create date: 24-01-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_InsertarAnalisisCromatografico]
    -- Add the parameters for the stored procedure here
    @IdTipoExcelPemex INT,
    @NombreArchivo NVARCHAR(MAX),
    @FechaReporte DATE,
    @ExcelArchivo IMAGE,
    @IdUsuario INT,
    @IdContrato INT,
    @CvPtoExpRec NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    /*Actualizar por contratista*/

    DECLARE @IdContratista INT;
    SELECT @IdContratista = CC.IdContratista
    FROM CO_Contratista CC
        JOIN CO_Contrato C
            ON CC.IdContratista = C.IdContratista
    WHERE C.IdContrato = @IdContrato;

    /**/

    IF EXISTS
    (
        SELECT *
        FROM PC_ExcelPemex EP
            JOIN CO_Contrato C
                ON EP.IdContrato = C.IdContrato
            JOIN CO_Contratista CC
                ON C.IdContratista = CC.IdContratista
        WHERE IdTipoExcelPemex = @IdTipoExcelPemex
              AND EP.FechaReporte = @FechaReporte
              AND CC.IdContratista = @IdContratista
		    AND EP.NombreArchivo = @NombreArchivo
    )
    BEGIN
        UPDATE EP
        SET ExcelArchivo = @ExcelArchivo,
            CreadoEn = GETDATE(),
            CreadoPor = @IdUsuario
        FROM PC_ExcelPemex EP
            JOIN CO_Contrato C
                ON EP.IdContrato = C.IdContrato
            JOIN CO_Contratista CC
                ON C.IdContratista = CC.IdContratista
        WHERE IdTipoExcelPemex = @IdTipoExcelPemex
              --AND EP.IdContrato = @IdContrato
              AND EP.FechaReporte = @FechaReporte
              AND CC.IdContratista = @IdContratista
		    AND EP.NombreArchivo = @NombreArchivo
    END;
    ELSE
    BEGIN
        INSERT INTO [dbo].[PC_ExcelPemex]
        (
            [IdTipoExcelPemex],
            [NombreArchivo],
            [FechaReporte],
            [ExcelArchivo],
            [CreadoPor],
            [CreadoEn],
            [IdContrato]
        )
        VALUES
        (@IdTipoExcelPemex, @NombreArchivo, @FechaReporte, @ExcelArchivo, @IdUsuario, GETDATE(), @IdContrato);
    END;
    IF (@IdTipoExcelPemex = 10006)
    BEGIN
        /*Determinar punto de expedición recepción*/
        DECLARE @IdPtoExpedicionRecepcion INT;
        DECLARE @CvPunto NVARCHAR(MAX);
        DECLARE @NombrePunto NVARCHAR(MAX);
        SELECT @IdPtoExpedicionRecepcion = IdPtoExpedicionRecepcion,
               @CvPunto = CvPunto,
               @NombrePunto = Denominacion
        FROM dbo.PC_PtoExpedicionRecepcion
        WHERE CvPunto = RTRIM(LTRIM(@CvPtoExpRec));
        /*SELECT @IdPtoExpedicionRecepcion AS IdPtoExpedicionRecepcion,
               @CvPunto AS CvPunto,
               @NombrePunto AS NombrePunto;*/
        /*Eliminar datos de la tabla para no duplicar daatos por mes, contrato, punto_exp-rec*/
        DELETE dbo.PC_AnalisisCromatograficoGas
        WHERE [MesReporte] = @FechaReporte
              AND IdPtoExpedicionRecepcion = @IdPtoExpedicionRecepcion
              AND IdContrato = @IdContrato;
        /*Insertar datos en tabla final de PC_AnalisisCromatograficoGas*/
        INSERT INTO [dbo].[PC_AnalisisCromatograficoGas]
        (
            [IdContrato],
            [MesReporte],
		  [IdPtoExpedicionRecepcion],
            [Dia],
            [Grav_H2Sppm],
            [PoderEspec_adm],
            [Poder_CO2mol],
            [Temp_N2mol],
            [Presion_C1mol],
            [C2mol],
            [C3mol],
            [IC4mol],
            [NC4mol],
            [IC5mol],
            [NC5mol],
            [C6mol],
            [PM_LBmol],
            [LIC_Bmmpc],
            [Cal_BTUf3],
          [Calorico_KCAm3],
            [GradosC],
            [KGcm2],
            [CreadoPor],
            [CreadoEn]
        )
        SELECT @IdContrato,
               @FechaReporte,
			@IdPtoExpedicionRecepcion,
               Dia,
               Grav_H2Sppm,
               PoderEspec_adm,
               Poder_CO2mol,
               Temp_N2mol,
               Presion_C1mol,
               C2mol,
               C3mol,
               IC4mol,
               NC4mol,
               IC5mol,
               NC5mol,
               C6mol,
               PM_LBmol,
               LIC_Bmmpc,
               REPLACE(Cal_BTUf3, ',', ''),
               REPLACE(Calorico_KCAm3, ',', ''),
               GradosC,
               KGcm2,
               @IdUsuario,
               GETDATE()
        FROM PC_Analisis
        WHERE Dia NOT LIKE '';
    END;
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;
