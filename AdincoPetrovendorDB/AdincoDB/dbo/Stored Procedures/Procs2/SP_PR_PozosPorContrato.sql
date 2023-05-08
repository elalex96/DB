create PROCEDURE SP_PR_PozosPorContrato
	@IdContrato int
	AS
	BEGIN 
	SELECT 
			p.RegionFiscal,
			p.Campo,
			p.Id,
			p.Nombre
	FROM PR_Pozo p
	inner join CO_Contrato c on c.IdContrato = @IdContrato
	inner join CO_PuntosdeEntregaContrato pec on pec.idContrato = c.IdContrato and
									pec.PuntoEntregaID = p.PuntoEntregaID
	END