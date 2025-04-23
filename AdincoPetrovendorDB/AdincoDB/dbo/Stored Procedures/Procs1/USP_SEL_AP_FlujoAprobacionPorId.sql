USE Adinco
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_ContratosFlujoAprobacionPorContratista'
    )
    DROP PROCEDURE USP_SEL_AP_ContratosFlujoAprobacionPorContratista;
GO
CREATE PROCEDURE USP_SEL_AP_ContratosFlujoAprobacionPorContratista
    @IdUsuario INT,
    @IdContrato INT,
	@IdContratistaSeleccionado INT,
	@FlujoAprobacionId INT
	AS  
BEGIN  
    SET NOCOUNT ON;
	
	SELECT 
		 CASE 
		 WHEN ISNULL(AP_FlujoAprobacionContratos.IdContrato,0) >0
		 THEN 1
		 ELSE ISNULL(AP_FlujoAprobacionContratos.IdContrato,0)
		 END AS Asignado,
		 CO_Contrato.IdContrato AS IdContratoFlujo,
		 NumeroContrato,
		 ISNULL(DescripcionContrato,'') AS DescripcionContrato
		FROM 
			CO_Contrato (NOLOCK)
		LEFT JOIN
			AP_FlujoAprobacionContratos	(NOLOCK)
		ON 
			CO_Contrato.IdContrato	=	AP_FlujoAprobacionContratos.IdContrato
			AND	AP_FlujoAprobacionContratos.FlujoAprobacionId	=	@FlujoAprobacionId
		WHERE 
			IdContratista = @IdContratistaSeleccionado;

END