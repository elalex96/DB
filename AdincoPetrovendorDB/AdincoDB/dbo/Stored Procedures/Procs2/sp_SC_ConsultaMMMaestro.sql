USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultaMMMaestro'
)
    DROP PROCEDURE sp_SC_ConsultaMMMaestro; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultaMMMaestro]    Script Date: 10/07/2023 09:36:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================
CREATE Proc [dbo].[sp_SC_ConsultaMMMaestro]
@pIdSubContrato int,
@pIdSubFamilia int
As
SET NOCOUNT ON;
	SELECT DISTINCT  MM.IdMaestro,
			MM.IdTipoCatalogoMaestro,
			MM.IdSubFamilia,
			MM.TextoCorto,
			MM.TextoLargo,
			IdUnidad =  MM.IdUnidadPreterminada,
			MM.IdMoneda,		
			MM.IdTipoMaterial,		
			MM.Prc,			
			MM.IsActivo,
			MM.IsEliminado,
			MM.CreadoPor,
			MM.CreadoEn,
			MM.ModificadoPor,
			MM.ModificadoEn
		FROM Petrovendor.dbo.[MM_Maestro] mm (NOLOCK)
		LEFT JOIN SC_Materiales scMAT (NOLOCK)
		ON mm.IdMaestro = scMAT.IdMaestro
		where mm.isactivo = 1 and mm.isEliminado = 0 
		AND IdTipoCatalogoMaestro = 2 AND		
		@pIdSubContrato in (0,scMAT.IdSubContrato) and
		@pIdSubFamilia in (0,mm.IdSubFamilia)
		order by MM.TextoCorto ASC
