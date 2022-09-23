USE Adinco
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_ConsultarComentariosEntregableInstancia'
)
    DROP PROCEDURE EN_ConsultarComentariosEntregableInstancia;
GO
/****** Object:  StoredProcedure [dbo].[EN_ConsultarComentariosEntregableInstancia]    Script Date: 22/09/2022 07:19:38 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:   Daniel AC  
-- Create date: 26/10/2020  
-- Description:  Consultar las comentarios de un entregable instancia
-- ============================================= 
CREATE PROCEDURE [dbo].[EN_ConsultarComentariosEntregableInstancia]
    @EntregableInstanciaId INT,
    @UsuarioId INT,
    @ContratoId INT	
AS
BEGIN

    /*SP PARA CONSULTAR LOS COMENTARIOS DE LOS USUARIOS*/
	--TABLA 1 DETALLE DEL ENTREGABLE INSTANCIA
    SELECT NoEntregableInstancia=IE.idInstanciaEntregable,
           DocumentoEntregable=EN.DocumentoEntregable		  
    FROM dbo.EN_InstanciasEntregable IE  (NOLOCK)
        JOIN dbo.EN_ContratoEntregable CE (NOLOCK)
            ON IE.IdContratoEntregable = CE.IdContratoEntregable
        JOIN dbo.EN_Entregable EN (NOLOCK)
            ON CE.IdEntregable = EN.IdEntregable
    WHERE IE.idInstanciaEntregable = @EntregableInstanciaId

	--TABLA 2 DETALLE DE LOS COMENTARIOS AGREGADOS
	SET LANGUAGE Spanish;
    SELECT Registro=EI.Id,
           Usuario=ISNULL(U.Nombre,''),
           Fecha=CONCAT(ISNULL(FORMAT(EI.CreadoEl, 'dd'),''), ' de ', ISNULL(DATENAME(month, EI.CreadoEl),''),' del ', ISNULL(FORMAT(EI.CreadoEl, 'yyyy'),''),' a las ', ISNULL(FORMAT(EI.CreadoEl, 'HH:mm'),'')),
           Comentario=ISNULL(EI.Comentario,'')
    FROM EN_EntregableInstanciaComentario EI (NOLOCK)
        JOIN dbo.AP_Usuario U (NOLOCK)
            ON EI.UsuarioId=U.UsuarioID 
    WHERE EI.EntregableInstanciaId = @EntregableInstanciaId
          AND EI.Activo = 1
    ORDER BY CreadoEl ASC;

END;

  
 