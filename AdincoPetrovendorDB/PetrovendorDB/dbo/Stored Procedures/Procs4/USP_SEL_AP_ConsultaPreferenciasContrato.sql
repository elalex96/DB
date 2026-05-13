USE [Petrovendor];
GO
IF OBJECT_ID('[dbo].[USP_SEL_AP_ConsultaPreferenciasContrato]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_SEL_AP_ConsultaPreferenciasContrato];
GO
/****** Object:  StoredProcedure [dbo].[USP_SEL_AP_ConsultaPreferenciasContrato]  ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21-04-2026
-- Description:	Obtiene los contratos configurados con la preferenciaId	
-- =============================================

CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultaPreferenciasContrato]
    @idUsuario INT = 0,
    @idContrato INT = 0,
    @idProveedor INT = 0,
    @idPreferencia INT 
AS
BEGIN
    select
		PC.Id,
		PC.ContratoId,
		PC.PreferenciaId,
		PC.Valor,
		PC.Activo,
		PC.CreadoEl,
		US.Nombre  AS CreadoPor,
		USM.Nombre AS ModificadoPor,
		PC.ModificadoEl
	from AP_PreferenciaContrato AS PC WITH (NOLOCK)
	left join S_Usuario AS US  WITH (NOLOCK) ON PC.CreadoPor    = US.IdUsuario
	left join S_Usuario AS USM WITH (NOLOCK) ON PC.ModificadoPor = USM.IdUsuario
    WHERE 
        pc.preferenciaId = @idPreferencia;
END;
GO