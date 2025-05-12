IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_DEL_AP_ContratosFlujoAprobacion'
    )
    DROP PROCEDURE USP_INS_DEL_AP_ContratosFlujoAprobacion;
GO
CREATE PROCEDURE USP_INS_DEL_AP_ContratosFlujoAprobacion
    @IdUsuario INT,
    @IdContrato INT,
	@IdContratistaSeleccionado INT,
	@FlujoAprobacionId INT,
	@IdContratoFlujo INT,
	@Asignado int
	AS  
BEGIN  
    SET NOCOUNT ON;
	
	IF( @Asignado = 1)
	BEGIN
		INSERT INTO AP_FlujoAprobacionContratos(FlujoAprobacionId,IdContrato,CreadoEl) VALUES (@FlujoAprobacionId,@IdContratoFlujo,GETDATE())
	END
	ELSE
	BEGIN
		DELETE  AP_FlujoAprobacionContratos WHERE IdContrato = @IdContratoFlujo AND FlujoAprobacionId = @FlujoAprobacionId;
	END
	
	
END
