IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_FlujoAprobacionPorId'
    )
    DROP PROCEDURE USP_SEL_AP_FlujoAprobacionPorId;
GO
CREATE PROCEDURE USP_SEL_AP_FlujoAprobacionPorId
    @IdUsuario INT,
    @IdContrato INT,
	@FlujoAprobacionId INT
	AS  
BEGIN  
    SET NOCOUNT ON;
	
	SELECT	FlujoAprobacionId,
			IdContratista,
			Descripcion,
			TipoFlujoAprobacionId,
			Activo,
			CreadoEl,
			CreadoPor
	FROM
		AP_FlujoAprobacion (NOLOCK)
	WHERE
		FlujoAprobacionId	=	@FlujoAprobacionId;

END