	CREATE PROCEDURE sp_CO_ObtenPuntoEntregaPorIdContrato --3,10061
	@IdContrato INT,
	@IdUsuario INT
	AS
BEGIN
    SET NOCOUNT ON;

		SELECT PE.Nombre AS Ubicacion ,PE.Nombre AS Descripcion, IdentificacionResponsable,Coordenadas,Latitud,Longitud  
		FROM 
			CO_PuntosdeEntregaContrato PEC
		JOIN
			CO_PuntosdeEntrega	PE
			ON	PEC.idContrato	= @IdContrato
			AND	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		WHERE
			PEC.Activo = 1
			AND PE.Activo	=1
	END;