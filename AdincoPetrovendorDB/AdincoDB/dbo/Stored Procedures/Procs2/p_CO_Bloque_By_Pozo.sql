
-- p_CO_Bloque_By_Pozo 10038,'OGARRIO 4'
create proc p_CO_Bloque_By_Pozo
@pIdContrato int,
@pPuntoEntrega varchar(500)
as

	SELECT B.*
	FROM CO_PuntosdeEntrega PE
	INNER JOIN [CO_PuntosdeEntregaContrato]  PEC ON PEC.PuntoEntregaID = pe.PuntoEntregaID
	INNER JOIN PR_Bloque B ON B.IdContrato = PEC.idContrato
	WHERE RTRIM(LTRIM(UPPER(PE.Nombre)))=RTRIM(LTRIM(UPPER(@pPuntoEntrega)))  AND
	PE.Activo = 1
