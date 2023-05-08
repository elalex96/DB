
CREATE proc [dbo].[sp_PRED_Previos_Ins]
(
	
	@IdPrevio			int	out,
	@IdPredio			int,
	@TabuladorIndaabin	varchar(8000),
	@Vigencia			datetime,
	@Gestor				varchar(50),
	@JefeCampo			varchar(50),
	@Descripcion		varchar(8000),
	@CreadoPor			int,
	@CreadoEl			datetime,
	@IdTipoBDT			int,
	@IdTipoInstalacion	int
)
as
begin

	
select	@IdPrevio	=	isnull(max(IdPrevio),0)+1 from PRED_PreVios
insert	into	PRED_Previos
				(	
					IdPrevio,
					IdPredio,
					TabuladorIndaabin,
					Vigencia,
					Gestor,
					JefeCampo,
					Descripcion,
					CreadoPor,
					CreadoEl,
					Activo,
					IdTipoBDT,
					IdTipoInstalacion
				)
			values
				(
					
					@IdPrevio,
					@IdPredio,
					@TabuladorIndaabin,
					@Vigencia,
					@Gestor,
					@JefeCampo,
					@Descripcion,
					@CreadoPor,
					@CreadoEl,
					1,
					@IdTipoBDT,
					@IdTipoInstalacion
				)
	
end