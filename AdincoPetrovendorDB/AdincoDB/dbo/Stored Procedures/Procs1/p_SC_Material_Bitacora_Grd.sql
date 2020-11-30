
CREATE PROC p_SC_Material_Bitacora_Grd
@pIdSubcontrato int
aS

SELECT	m.Concepto,
		m.Descripcion,
		mb.CantidadRespaldo,
		mb.PrecioUnitario,
		FechaMOdificacion=mb.FechaRespaldo,
		ModificadoPor = ISNULL(u.Nombre,'')
FROM
	SC_MaterialesBitacora mb
INNER JOIN 
	SC_Materiales m 
	ON mb.IdSCMaterial = m.IdSCMaterial
	AND m.IdSubcontrato = @pIdSubcontrato 
LEFT JOIN 
	AP_Usuario u 
	ON  mb.ModificadoPor = u.UsuarioId
WHERE 
	m.IdSubcontrato = @pIdSubcontrato
ORDER BY 
	mb.FechaRespaldo DESC