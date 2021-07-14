USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_S_Usuario_Cmb'
)
    DROP PROCEDURE sp_S_Usuario_Cmb;

/****** Object:  StoredProcedure [dbo].[sp_S_Usuario_Cmb]    Script Date: 13/07/2021 12:50:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_S_Usuario_Cmb]
as
begin
		select	IdUsuario,
				Nombre
		from	S_Usuario
		where	Activo = 1
		and		isnull(IsEliminado,0) = 0
		order by Nombre asc 
end