USE [Petrovendor]
GO


IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'spCentroCostoFiltroIns'
)
    DROP PROCEDURE spCentroCostoFiltroIns;

/****** Object:  StoredProcedure [dbo].[spCentroCostoFiltroIns]    Script Date: 13/07/2021 12:50:51 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[spCentroCostoFiltroIns]
(
	@IdCentroCosto	int,
	@IdUsuario		int,
	@IdProveedor	int
)
as
begin
	if exists(
		select * 
		from	CentroCostoFiltro 
		where	IdCentroCosto		=	@IdCentroCosto
		and		IdUsuario			=	@IdUsuario
		and		IdProveedor			=	@IdProveedor
	)
	begin
			update	CentroCostoFiltro 
			set		Activo				=	1,
					ModificadoEl		=	getdate()
			where	IdCentroCosto		=	@IdCentroCosto
			and		IdUsuario			=	@IdUsuario
			and		IdProveedor			=	@IdProveedor
	end
	else
	begin
	
		insert into CentroCostoFiltro
					(
						IdCentroCosto,
						IdUsuario,
						IdProveedor,
						Activo,
						CreadoEl,
						ModificadoEl
					)
				values
					(
						@IdCentroCosto,
						@IdUsuario,
						@IdProveedor,
						1,
						getdate(),
						null
					)
	end
end