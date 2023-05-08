-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCatMaestroJSON]
AS
BEGIN


	--SELECT '{' + '"MM_Maestro":' + '[' + STUFF((
 --   SELECT   
	--   ',{"IdMaestro": "' + cast(IdMaestro as varchar(max)) + '"' +
	--   ',"IdTipoCatalogoMaestro": "' + cast(IdTipoCatalogoMaestro as varchar(max)) + '"' +
	--   ',"IdSubFamilia": "' + cast(IdSubFamilia as varchar(max)) + '"' +
	--   ',"CodSubFamilia": "' + cast(CodSubFamilia as varchar(max)) + '"' +
	--   ',"TextoCorto": "' + TextoCorto + ' "' +
	--   ',"TextoLargo": "' + cast(TextoLargo as varchar(max)) + '"' +
	--   --',"IdUnidad":' + cast(IdUnidad as varchar(max)) +
	--   ',"UMB": "' + cast(UMB as varchar(max)) + '"' +
	--   ',"IdMoneda": "' + cast(IdMoneda as varchar(max)) + '"' +
	--   ',"Precio": "' + cast(Precio as varchar(max)) + '"' +
	--   ',"IdTipoMaterial": "' + cast(IdTipoMaterial as varchar(max)) + '"' +
	--   ',"NoMatAnti": "' + cast(NoMatAnti as varchar(max)) + '"' +
	--   ',"Ce": "' + cast(Ce as varchar(max)) + '"' +
	--   ',"Material": "' + cast(Material as varchar(max)) + '"' +
	--   ',"Prc": "' + cast(Prc as varchar(max)) + '"' +
	--   ',"Entre": "' + cast(Entre as varchar(max)) + '"' +
	--   ',"CatVa": "' + cast(CatVa as varchar(max)) + '"' +
	--   ',"UltMod": "' + cast(UltMod as varchar(max)) + '"' +
	--   --',"CaP":' + cast(CaP as varchar(max)) +
	--   --',"ClValor":' + cast(ClValor as varchar(max)) +
	--   --',"GCp":' + cast(GCp as varchar(max)) +
	--   --',"ABC":' + cast(ABC as varchar(max)) +
	--   --',"Servicio":' + cast(Servicio as varchar(max)) +
	--   --',"TipoServicio":' + cast(TipoServicio as varchar(max)) +
	--   --',"CatValor":' + cast(CatValor as varchar(max)) +
	--   --',"IdImpuesto":' + cast(IdImpuesto as varchar(max)) +
	--   --',"Denomin":' + cast(Denomin as varchar(max)) +
	--   ',"Creado": "' + cast(Creado as varchar(max)) + '"' +
	--   --',"Modificado":' + cast(Modificado as varchar(max)) +
	--   ',"IsActivo": "' + cast(IsActivo as varchar(max)) + '"' +
	--   ',"IsEliminado": "' + cast(IsEliminado as varchar(max)) + '"' +
	--   ',"CreadoPor": "' + cast(CreadoPor as varchar(max)) + '"' +
	--   ',"CreadoEn": "' + cast(CreadoEn as varchar(max)) + '"' +
	--   --',"ModificadoPor":' + cast(ModificadoPor as varchar(max)) +
	--   --',"ModificadoEn":' + cast(ModificadoEn as varchar(max)) 
	--   +'}'
	              
	--	FROM MM_Maestro 
	--	FOR XML PATH(''),ELEMENTS XSINIL, TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') + ']' + '}'


   SELECT '{' + '"MM_Maestro":' + '[' + SUBSTRING(
     (
    SELECT  
	   ',{"IdMaestro": "' + cast(IdMaestro as varchar(max)) + '"' +
	   --',"IdTipoCatalogoMaestro": "' + cast(IdTipoCatalogoMaestro as varchar(max)) + '"' +
	   --',"IdSubFamilia": "' + cast(IdSubFamilia as varchar(max)) + '"' +
	   --',"CodSubFamilia": "' + cast(CodSubFamilia as varchar(max)) + '"' +
	   ',"TextoCorto": "' + TextoCorto + ' "' +
	   --',"TextoLargo": "' + cast(TextoLargo as varchar(max)) + '"' +
	   --',"IdUnidad":' + cast(ISNULL(IdUnidad,0) as varchar(max)) +
	   --',"UMB": "' + cast(UMB as varchar(max)) + '"' +
	   --',"IdMoneda": "' + cast(IdMoneda as varchar(max)) + '"' +
	   --',"Precio": "' + cast(Precio as varchar(max)) + '"' +
	   --',"IdTipoMaterial": "' + cast(IdTipoMaterial as varchar(max)) + '"' +
	   --',"NoMatAnti": "' + cast(NoMatAnti as varchar(max)) + '"' +
	   --',"Ce": "' + cast(Ce as varchar(max)) + '"' +
	   --',"Material": "' + cast(Material as varchar(max)) + '"' +
	   --',"Prc": "' + cast(Prc as varchar(max)) + '"' +
	   --',"Entre": "' + cast(Entre as varchar(max)) + '"' +
	   --',"CatVa": "' + cast(CatVa as varchar(max)) + '"' +
	   --',"UltMod": "' + cast(UltMod as varchar(max)) + '"' +
	   --',"CaP":' + cast(ISNULL(CaP,0) as varchar(max)) +
	   --',"ClValor":' + cast(ISNULL(ClValor,0) as varchar(max)) +
	   --',"GCp":' + cast(ISNULL(GCp,0) as varchar(max)) +
	   --',"ABC":' + cast(ISNULL(ABC,0) as varchar(max)) +
	   --',"Servicio":' + cast(ISNULL(Servicio,0) as varchar(max)) +
	   --',"TipoServicio":' + cast(ISNULL(TipoServicio,0) as varchar(max)) +
	   --',"CatValor":' + cast(ISNULL(CatValor,0) as varchar(max)) +
	   --',"IdImpuesto":' + cast(ISNULL(IdImpuesto,0) as varchar(max)) +
	   --',"Denomin":' + cast(ISNULL(Denomin,0) as varchar(max)) +
	   --',"Creado": "' + cast(Creado as varchar(max)) + '"' +
	   --',"Modificado":' + cast(ISNULL(Modificado,0) as varchar(max)) +
	   --',"IsActivo": "' + cast(IsActivo as varchar(max)) + '"' +
	   --',"IsEliminado": "' + cast(IsEliminado as varchar(max)) + '"' +
	   --',"CreadoPor": "' + cast(CreadoPor as varchar(max)) + '"' +
	   --',"CreadoEn": "' + cast(CreadoEn as varchar(max)) + '"' +
	   --',"ModificadoPor":' + cast(ISNULL(ModificadoPor,0) as varchar(max)) +
	   --',"ModificadoEn":' + cast(ISNULL(ModificadoEn,0) as varchar(max)) 
	   +'}'
        FROM MM_Maestro 
        FOR XML PATH('')
     ), 2 , 10000000)  + ']' + '}'


  --   declare @JsonString NVARCHAR(MAX)
	 --select @JsonString = coalesce(@JsonString +  ',{"IdMaestro": "' + cast(IdMaestro as varchar(max)) + '"' + 
	 --',"IdTipoCatalogoMaestro": "' + cast(IdTipoCatalogoMaestro as varchar(max)) + '"' +
	 --	   ',"IdSubFamilia": "' + cast(IdSubFamilia as varchar(max)) + '"' +
	 --  ',"CodSubFamilia": "' + cast(CodSubFamilia as varchar(max)) + '"' +
	 --  ',"TextoCorto": "' + TextoCorto + ' "' +
	 --  ',"TextoLargo": "' + cast(TextoLargo as varchar(max)) + '"' +
	 --  --',"IdUnidad":' + cast(IdUnidad as varchar(max)) +
	 --  ',"UMB": "' + cast(UMB as varchar(max)) + '"' +
	 --  ',"IdMoneda": "' + cast(IdMoneda as varchar(max)) + '"' +
	 --  ',"Precio": "' + cast(Precio as varchar(max)) + '"' +
	 --  ',"IdTipoMaterial": "' + cast(IdTipoMaterial as varchar(max)) + '"' +
	 --  ',"NoMatAnti": "' + cast(NoMatAnti as varchar(max)) + '"' +
	 --  ',"Ce": "' + cast(Ce as varchar(max)) + '"' +
	 --  ',"Material": "' + cast(Material as varchar(max)) + '"' +
	 --  ',"Prc": "' + cast(Prc as varchar(max)) + '"' +
	 --  ',"Entre": "' + cast(Entre as varchar(max)) + '"' +
	 --  ',"CatVa": "' + cast(CatVa as varchar(max)) + '"' +
	 --  ',"UltMod": "' + cast(UltMod as varchar(max)) + '"' +
	 --  ',"CaP":' + cast(ISNULL(CaP,0) as varchar(max)) +
	 --  ',"ClValor":' + cast(ISNULL(ClValor,0) as varchar(max)) +
	 --  ',"GCp":' + cast(ISNULL(GCp,0) as varchar(max)) +
	 --  ',"ABC":' + cast(ISNULL(ABC,0) as varchar(max)) +
	 --  ',"Servicio":' + cast(ISNULL(Servicio,0) as varchar(max)) +
	 --  ',"TipoServicio":' + cast(ISNULL(TipoServicio,0) as varchar(max)) +
	 --  ',"CatValor":' + cast(ISNULL(CatValor,0) as varchar(max)) +
	 --  ',"IdImpuesto":' + cast(ISNULL(IdImpuesto,0) as varchar(max)) +
	 --  ',"Denomin":' + cast(ISNULL(Denomin,0) as varchar(max)) +
	 --  ',"Creado": "' + cast(Creado as varchar(max)) + '"' +
	 --  ',"Modificado":' + cast(ISNULL(Modificado,0) as varchar(max)) +
	 --  ',"IsActivo": "' + cast(IsActivo as varchar(max)) + '"' +
	 --  ',"IsEliminado": "' + cast(IsEliminado as varchar(max)) + '"' +
	 --  ',"CreadoPor": "' + cast(CreadoPor as varchar(max)) + '"' +
	 --  ',"CreadoEn": "' + cast(CreadoEn as varchar(max)) + '"' +
	 --  ',"ModificadoPor":' + cast(ISNULL(ModificadoPor,0) as varchar(max)) +
	 --  ',"ModificadoEn":' + cast(ISNULL(ModificadoEn,0) as varchar(max)) +
	 --'}','') from MM_Maestro 

  --   select @JsonString

	 --create table #JsonResult(
	 --JsonString NVARCHAR(MAX)
	 --)
	 
	
	 --insert into #JsonResult(JsonString)values(@JsonString) 

	 --select * from #JsonResult
END

