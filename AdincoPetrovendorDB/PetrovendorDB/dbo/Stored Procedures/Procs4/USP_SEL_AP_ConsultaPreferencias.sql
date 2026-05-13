USE [Petrovendor];
GO
IF OBJECT_ID('[dbo].[USP_SEL_AP_ConsultaPreferencias]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_SEL_AP_ConsultaPreferencias];
GO

/****** Object:  StoredProcedure [dbo].[USP_SEL_AP_ConsultaPreferencias]  ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21-04-2026
-- Description:	Obtiene las preferencias para la administracion
-- =============================================

CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultaPreferencias]
    @idUsuario INT = 0,
    @idContrato INT = 0,
    @idProveedor INT = 0
AS
BEGIN
    SELECT 
        p.Id,
        p.Nombre,
        p.Descripcion,
        p.EsDeUsuario,
        p.EsDeProveedor,
        p.EsDeContrato,
        p.RequiereValor,
        p.Activo,
        p.CreadoEl,
        US.Nombre  AS CreadoPor,
		USM.Nombre AS ModificadoPor,
        p.ModificadoEl 
    FROM 
        AP_Preferencias AS p WITH (NOLOCK)
	left join S_Usuario AS US  WITH (NOLOCK) ON P.CreadoPor    = US.IdUsuario
	left join S_Usuario AS USM WITH (NOLOCK) ON P.ModificadoPor = USM.IdUsuario;
END;
GO