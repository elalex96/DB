
-- sp_SC_ConsultaMMMaestro 1,0
Create Proc sp_SC_ConsultaMMMaestro
@pIdSubContrato int,
@pIdSubFamilia int

As

	SELECT DISTINCT  MM.IdMaestro,
			MM.IdTipoCatalogoMaestro,
			MM.IdSubFamilia,
			--MM.CodSubFamilia,
			MM.TextoCorto,
			MM.TextoLargo,
			IdUnidad =  MM.IdUnidadPreterminada,
			--MM.UMB,
			MM.IdMoneda,
			--MM.Precio,
			MM.IdTipoMaterial,
			--MM.NoMatAnti,
			--MM.Ce,
			--MM.Material,
			MM.Prc,
			--MM.Entre,
			--MM.CatVa,
			--MM.UltMod,
			--MM.CaP,
			--MM.ClValor,
			--MM.GCp,
			--MM.ABC,
			--MM.Servicio,
			--MM.TipoServicio,
			--MM.CatValor,
			--MM.IdImpuesto,
			--MM.Denomin,
			--MM.Creado,
			--MM.Modificado,
			MM.IsActivo,
			MM.IsEliminado,
			MM.CreadoPor,
			MM.CreadoEn,
			MM.ModificadoPor,
			MM.ModificadoEn
		FROM Petrovendor.dbo.[MM_Maestro] mm
		LEFT join SC_Materiales scMAT ON scMAT.IdMaestro = mm.IdMaestro
		where isactivo = 1 and isEliminado = 0 
		AND IdTipoCatalogoMaestro = 2 AND		
		@pIdSubContrato in (0,scMAT.IdSubContrato) and
		@pIdSubFamilia in (0,mm.IdSubFamilia)
		order by MM.TextoCorto
