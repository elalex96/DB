Create proc [dbo].[sp_SC_BajaSubContrato]
@pIdSubContrato int,
@pModificadoPor int
As

	Update SC_SubContrato
	set IsActivo = 0,
		IsEliminado = 1,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = GETDATE()
	where IdSubContrato = @pIdSubContrato
