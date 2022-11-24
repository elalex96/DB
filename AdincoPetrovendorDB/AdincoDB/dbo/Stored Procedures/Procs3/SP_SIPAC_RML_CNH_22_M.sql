-- =============================================
-- Author:		Alexander Gomez
-- Create date: 07/05/2018
-- Description:	Insercion en la tabla para reporte RML_CNH_22_M
-- =============================================
CREATE PROCEDURE SP_SIPAC_RML_CNH_22_M
	-- Add the parameters for the stored procedure here
	@RF_00 NVARCHAR(255),
	@RI_00 NVARCHAR(255),
	@RF01_01 NVARCHAR(255),
	@RMLCH22_00 INT,
	@RMLCH22_01 INT,
	@RMLCH22_02 FLOAT,
	@RMLCH22_03 FLOAT,
	@RMLCH22_04 FLOAT,
	@RMLCH22_05 FLOAT,
	@RMLCH22_06 FLOAT,
	@RMLCH22_07 FLOAT,
	@RMLCH22_08 FLOAT,
	@RMLCH22_09 FLOAT,
	@RMLCH22_10 FLOAT,
	@RMLCH22_11 FLOAT,
	@RMLCH22_12 FLOAT,
	@RMLCH22_13 FLOAT,
	@RMLCH22_14 FLOAT,
	@RMLCH22_15 FLOAT,
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTEREGISTROVOL22 INT;

	SET @EXISTEREGISTROVOL22 = (SELECT COUNT(*) FROM dbo.SIPAC_RML_CNH_22_M WHERE [ID del contrato asignado por CNH (RF01_01)] = @RF01_01 AND [Mes de reporte (RMLCH22_00)] = @RMLCH22_00 AND [Año de reporte (RMLCH22_01)] = @RMLCH22_01 AND IdContrato = @IdContrato)

	IF @EXISTEREGISTROVOL22 > 0
	BEGIN
		UPDATE dbo.SIPAC_RML_CNH_22_M 
		SET [ID del contratista asignado por el SIPAC (RF_00)] = @RF_00,
			[ID registro fiduciario del contrato (RI_00)] = @RI_00,
			[ID del contrato asignado por CNH (RF01_01)] = @RF01_01,
			[Mes de reporte (RMLCH22_00)] = @RMLCH22_00,
			[Año de reporte (RMLCH22_01)] = @RMLCH22_01,
			[Volumen de producción de petróleo registrado en el punto de medición (RMLCH22_02)] = @RMLCH22_02,
			[Grados API del petróleo producido, promedio ponderado (RMLCH22_03)] = @RMLCH22_03,
			[Contenido de azufre del petróleo producido, promedio ponderado (RMLCH22_04)] = @RMLCH22_04,
			[Volumen de petróleo producido destinado al autoconsumo (RMLCH22_05)] = @RMLCH22_05,
			[Volumen de producción del componente metano de gas natural asociado registrado en el punto de medición (RMLCH22_06)] = @RMLCH22_06,
			[Volumen de producción del componente etano de gas natural asociado registrado en el punto de medición (RMLCH22_07)] = @RMLCH22_07,
			[Volumen de producción del componente propano de gas natural asociado registrado en el punto de medición (RMLCH22_08)] = @RMLCH22_08,
			[Volumen de producción del componente butano de gas natural asociado registrado en el punto de medición (RMLCH22_09)] = @RMLCH22_09,
			[Volumen del componente metano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_10)] = @RMLCH22_10,
			[Volumen del componente etano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_11)] = @RMLCH22_11,
			[Volumen del componente propano de gas natural asociado producido destinado al autoconsumo destrucción controlada (RMLCH22_12)] = @RMLCH22_12,
			[Volumen del componente butano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_13)] = @RMLCH22_13,
			[Volumen de producción de condensados registrado en el punto de medición (RMLCH22_14)] = @RMLCH22_14,
			[Volumen de condensados producidos destinados al autoconsumo (RMLCH22_15)] = @RMLCH22_15,
			IdUsuario = @IdUsuario,
			IdContrato = @IdContrato
		WHERE [ID del contrato asignado por CNH (RF01_01)] = @RF01_01 AND [Mes de reporte (RMLCH22_00)] = @RMLCH22_00 AND [Año de reporte (RMLCH22_01)] = @RMLCH22_01
	END
	ELSE
	BEGIN

    -- Insert statements for procedure here
	INSERT INTO dbo.SIPAC_RML_CNH_22_M
	(
	    [ID del contratista asignado por el SIPAC (RF_00)],
	    [ID registro fiduciario del contrato (RI_00)],
	    [ID del contrato asignado por CNH (RF01_01)],
	    [Mes de reporte (RMLCH22_00)],
	    [Año de reporte (RMLCH22_01)],
	    [Volumen de producción de petróleo registrado en el punto de medición (RMLCH22_02)],
	    [Grados API del petróleo producido, promedio ponderado (RMLCH22_03)],
	    [Contenido de azufre del petróleo producido, promedio ponderado (RMLCH22_04)],
	    [Volumen de petróleo producido destinado al autoconsumo (RMLCH22_05)],
	    [Volumen de producción del componente metano de gas natural asociado registrado en el punto de medición (RMLCH22_06)],
	    [Volumen de producción del componente etano de gas natural asociado registrado en el punto de medición (RMLCH22_07)],
	    [Volumen de producción del componente propano de gas natural asociado registrado en el punto de medición (RMLCH22_08)],
	    [Volumen de producción del componente butano de gas natural asociado registrado en el punto de medición (RMLCH22_09)],
	    [Volumen del componente metano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_10)],
	    [Volumen del componente etano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_11)],
	    [Volumen del componente propano de gas natural asociado producido destinado al autoconsumo destrucción controlada (RMLCH22_12)],
	    [Volumen del componente butano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_13)],
	    [Volumen de producción de condensados registrado en el punto de medición (RMLCH22_14)],
	    [Volumen de condensados producidos destinados al autoconsumo (RMLCH22_15)],
		IdUsuario,
		IdContrato
	)
	VALUES
	(   @RF_00, -- ID del contratista asignado por el SIPAC (RF_00) - nvarchar(255)
	    @RI_00, -- ID registro fiduciario del contrato (RI_00) - nvarchar(255)
	    @RF01_01, -- ID del contrato asignado por CNH (RF01_01) - nvarchar(255)
	    @RMLCH22_00,   -- Mes de reporte (RMLCH22_00) - int
	    @RMLCH22_01,   -- Año de reporte (RMLCH22_01) - int
	    @RMLCH22_02, -- Volumen de producción de petróleo registrado en el punto de medición (RMLCH22_02) - float
	    @RMLCH22_03, -- Grados API del petróleo producido, promedio ponderado (RMLCH22_03) - float
	    @RMLCH22_04, -- Contenido de azufre del petróleo producido, promedio ponderado (RMLCH22_04) - float
	    @RMLCH22_05, -- Volumen de petróleo producido destinado al autoconsumo (RMLCH22_05) - float
	    @RMLCH22_06, -- Volumen de producción del componente metano de gas natural asociado registrado en el punto de medición (RMLCH22_06) - float
	    @RMLCH22_07, -- Volumen de producción del componente etano de gas natural asociado registrado en el punto de medición (RMLCH22_07) - float
	    @RMLCH22_08, -- Volumen de producción del componente propano de gas natural asociado registrado en el punto de medición (RMLCH22_08) - float
	    @RMLCH22_09, -- Volumen de producción del componente butano de gas natural asociado registrado en el punto de medición (RMLCH22_09) - float
	    @RMLCH22_10, -- Volumen del componente metano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_10) - float
	    @RMLCH22_11, -- Volumen del componente etano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_11) - float
	    @RMLCH22_12, -- Volumen del componente propano de gas natural asociado producido destinado al autoconsumo destrucción controlada (RMLCH22_12) - float
	    @RMLCH22_13, -- Volumen del componente butano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_13) - float
	    @RMLCH22_14, -- Volumen de producción de condensados registrado en el punto de medición (RMLCH22_14) - float
	    @RMLCH22_15,  -- Volumen de condensados producidos destinados al autoconsumo (RMLCH22_15) - float
	    @IdUsuario,
		@IdContrato
		)

	END
END
