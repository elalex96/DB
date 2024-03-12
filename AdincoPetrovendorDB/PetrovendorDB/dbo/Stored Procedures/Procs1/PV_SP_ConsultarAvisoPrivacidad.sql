USE [Petrovendor]
GO
  IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'PV_SP_ConsultarAvisoPrivacidad'
)
DROP PROCEDURE PV_SP_ConsultarAvisoPrivacidad;   
GO 
/****** Object:  StoredProcedure [dbo].[PV_SP_ConsultarAvisoPrivacidad]    Script Date: 09/08/2022 01:56:58 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel Ac
-- Create date: 11/03/2024
-- Description:	Consultar aviso de privacidad o politicas de seguridad
-- =============================================

CREATE PROCEDURE [dbo].[PV_SP_ConsultarAvisoPrivacidad]	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null,
	@Descripcion VARCHAR(200) = null
AS
BEGIN

	SELECT AvisoPrivacidad 
	FROM dbo.PV_AvisoPrivacidad (NOLOCK)
	WHERE Descripcion = @Descripcion

END
