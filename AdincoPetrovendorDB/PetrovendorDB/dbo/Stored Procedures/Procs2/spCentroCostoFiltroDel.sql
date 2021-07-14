USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'spCentroCostoFiltroDel'
)
    DROP PROCEDURE spCentroCostoFiltroDel;
/****** Object:  StoredProcedure [dbo].[spCentroCostoFiltroDel]    Script Date: 13/07/2021 12:50:08 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spCentroCostoFiltroDel]
(
	@IdCentroCosto	int,
	@IdUsuario		int,
	@IdProveedor	int
)
as
begin

			update	CentroCostoFiltro 
			set		Activo				=	0,
					ModificadoEl		=	getdate()
			where	IdCentroCosto		=	@IdCentroCosto
			and		IdUsuario			=	@IdUsuario
			and		IdProveedor			=	@IdProveedor
	
end