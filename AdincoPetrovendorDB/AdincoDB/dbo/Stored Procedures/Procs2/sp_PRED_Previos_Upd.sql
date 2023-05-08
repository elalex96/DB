
CREATE proc [dbo].[sp_PRED_Previos_Upd]
(
	
	@IdPrevio			int,
	@IdPredio			int,
	@TabuladorIndaabin	varchar(8000),
	@Vigencia			datetime,
	@Gestor				varchar(50),
	@JefeCampo			varchar(50),
	@Descripcion		varchar(8000),
	@ModificadoPor		int,
	@ModificadoEl		datetime,
	@Activo				bit,
	@IdTipoBDT			int,
	@IdTipoInstalacion	int
)
as
begin

	
		update		PRED_Previos
		set	
					IdPredio			=	@IdPredio,
					TabuladorIndaabin	=	@TabuladorIndaabin,
					Vigencia			=	@Vigencia,
					Gestor				=	@Gestor,
					JefeCampo			=	@JefeCampo,
					Descripcion			=	@Descripcion,
					ModificadoPor		=	@ModificadoPor,
					ModificadoEl		=	@ModificadoEl,
					Activo				=	@Activo,
					IdTipoBDT			=	@IdTipoBDT,
					IdTipoInstalacion	=	@IdTipoInstalacion
		where		IdPrevio			=	@IdPrevio
				
end