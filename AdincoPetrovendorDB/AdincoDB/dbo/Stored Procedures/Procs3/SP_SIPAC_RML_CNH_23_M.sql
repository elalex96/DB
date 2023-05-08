-- =============================================
-- Author:		Alexander Gomez
-- Create date: 07/05/2018
-- Description:	Insercion del reporte RML_CNH_23_M
-- =============================================
create PROCEDURE SP_SIPAC_RML_CNH_23_M
	-- Add the parameters for the stored procedure here
	@RF_00 NVARCHAR(255),
	@RI_00 NVARCHAR(255),
	@RF01_01 NVARCHAR(255),
	@RMLCH23_00 INT,
	@RMLCH23_01 INT,
	@RMLCH23_02 FLOAT,
	@RMLCH23_03 FLOAT,
	@RMLCH23_04 FLOAT,
	@RMLCH23_05 FLOAT,
	@RMLCH23_06 FLOAT,
	@RMLCH23_07 FLOAT,
	@RMLCH23_08 FLOAT,
	@RMLCH23_09 FLOAT,
	@RMLCH23_10 FLOAT,
	@RMLCH23_11 FLOAT,
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTEREGISTROVOL23 INT;

	SET @EXISTEREGISTROVOL23 = (SELECT COUNT(*) FROM dbo.SIPAC_RML_CNH_23_M WHERE [ID del contrato asignado por CNH (RF01_01)] = @RF01_01 AND [Mes de reporte (RMLCH23_00)] = @RMLCH23_00 AND [Año de reporte (RMLCH23_01)] = @RMLCH23_01 AND IdContrato = @IdContrato)

	IF @EXISTEREGISTROVOL23 > 0
	BEGIN

	UPDATE dbo.SIPAC_RML_CNH_23_M
	SET [ID del contratista asignado por el SIPAC (RF_00)] = @RF_00,
	    [ID registro fiduciario del contrato (RI_00)] = @RI_00,
	    [ID del contrato asignado por CNH (RF01_01)] = @RF01_01,
	    [Mes de reporte (RMLCH23_00)] = @RMLCH23_00,
	    [Año de reporte (RMLCH23_01)] = @RMLCH23_01,
	    [Volumen de producción del componente metano de gas natural no asociado registrado en el punto de medición (RMLCH23_02)] = @RMLCH23_02,
	    [Volumen de producción del componente etano de gas natural no asociado registrado en el punto de medición (RMLCH23_03)] = @RMLCH23_03,
	    [Volumen de producción del componente propano de gas natural no asociado registrado en el punto de medición (RMLCH23_04)] = @RMLCH23_04,
	    [Volumen de producción del componente butano de gas natural no asociado registrado en el punto de medición (RMLCH23_05)] = @RMLCH23_05,
	    [Volumen del componente metano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_06)] = @RMLCH23_06,
	    [Volumen del componente etano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_07)] = @RMLCH23_07,
	    [Volumen del componente propano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_08)] = @RMLCH23_08,
	    [Volumen del componente butano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_09)] = @RMLCH23_09,
	    [Volumen de producción de condensados registrado en el punto de medición (RMLCH23_10)] = @RMLCH23_10,
	    [Volumen de condensados producidos destinados al autoconsumo (RMLCH23_11)] = @RMLCH23_11,
		IdUsuario = @IdUsuario,
		IdContrato = @IdContrato
	WHERE [ID del contrato asignado por CNH (RF01_01)] = @RF01_01 AND [Mes de reporte (RMLCH23_00)] = @RMLCH23_00 AND [Año de reporte (RMLCH23_01)] = @RMLCH23_01
	
	
	END
	ELSE
	BEGIN
    -- Insert statements for procedure here
	INSERT INTO dbo.SIPAC_RML_CNH_23_M
	(
	    [ID del contratista asignado por el SIPAC (RF_00)],
	    [ID registro fiduciario del contrato (RI_00)],
	    [ID del contrato asignado por CNH (RF01_01)],
	    [Mes de reporte (RMLCH23_00)],
	    [Año de reporte (RMLCH23_01)],
	    [Volumen de producción del componente metano de gas natural no asociado registrado en el punto de medición (RMLCH23_02)],
	    [Volumen de producción del componente etano de gas natural no asociado registrado en el punto de medición (RMLCH23_03)],
	    [Volumen de producción del componente propano de gas natural no asociado registrado en el punto de medición (RMLCH23_04)],
	    [Volumen de producción del componente butano de gas natural no asociado registrado en el punto de medición (RMLCH23_05)],
	    [Volumen del componente metano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_06)],
	    [Volumen del componente etano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_07)],
	    [Volumen del componente propano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_08)],
	    [Volumen del componente butano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_09)],
	    [Volumen de producción de condensados registrado en el punto de medición (RMLCH23_10)],
	    [Volumen de condensados producidos destinados al autoconsumo (RMLCH23_11)],
		IdUsuario,
		IdContrato
	)
	VALUES
	(   @RF_00, -- ID del contratista asignado por el SIPAC (RF_00) - nvarchar(255)
	    @RI_00, -- ID registro fiduciario del contrato (RI_00) - nvarchar(255)
	    @RF01_01, -- ID del contrato asignado por CNH (RF01_01) - nvarchar(255)
	    @RMLCH23_00,   -- Mes de reporte (RMLCH23_00) - int
	    @RMLCH23_01,   -- Año de reporte (RMLCH23_01) - int
	    @RMLCH23_02, -- Volumen de producción del componente metano de gas natural no asociado registrado en el punto de medición (RMLCH23_02) - float
	    @RMLCH23_03, -- Volumen de producción del componente etano de gas natural no asociado registrado en el punto de medición (RMLCH23_03) - float
	    @RMLCH23_04, -- Volumen de producción del componente propano de gas natural no asociado registrado en el punto de medición (RMLCH23_04) - float
	    @RMLCH23_05, -- Volumen de producción del componente butano de gas natural no asociado registrado en el punto de medición (RMLCH23_05) - float
	    @RMLCH23_06, -- Volumen del componente metano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_06) - float
	    @RMLCH23_07, -- Volumen del componente etano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_07) - float
	    @RMLCH23_08, -- Volumen del componente propano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_08) - float
	    @RMLCH23_09, -- Volumen del componente butano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_09) - float
	    @RMLCH23_10, -- Volumen de producción de condensados registrado en el punto de medición (RMLCH23_10) - float
	    @RMLCH23_11,  -- Volumen de condensados producidos destinados al autoconsumo (RMLCH23_11) - float
	    @IdUsuario,
		@IdContrato
		)

	END
END
