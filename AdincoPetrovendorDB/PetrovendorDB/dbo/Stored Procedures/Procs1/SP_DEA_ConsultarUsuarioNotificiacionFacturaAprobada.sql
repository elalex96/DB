/****** Object:  StoredProcedure [dbo].[SP_DEA_ConsultarUsuarioNotificiacionFacturaAprobada]    Script Date: 06/10/2020 16:42:04 ******/
-- =============================================  
CREATE PROCEDURE [dbo].[SP_DEA_ConsultarUsuarioNotificiacionFacturaAprobada]  
 -- Add the parameters for the stored procedure here  
 @IdProveedor int,   
 @IdUsuario INT
AS
BEGIN
 DECLARE  @Usuarios table
 (  
   IdUsuario int,  
   Nombre varchar(max),  
   Correo varchar(max)  
 )  
 --VALIDACION DE ENVIO DE FACTURA PARA DEMMA Y LOS DEMAS CONTRATOS DE DEA  
 IF @IdProveedor = 2975--DEMMA  
 BEGIN
   INSERT INTO @Usuarios (IdUsuario,Nombre,Correo)  
   VALUES
   ( 4968, 'Invoice Mexico', 'invoice.mexico@wintershalldea.com')   
 END  
 ELSE  
 BEGIN
   INSERT INTO @Usuarios (IdUsuario,Nombre,Correo)  
   VALUES
   (4180, 'Invoice Mexico', 'invoice.mexico@wintershalldea.com')   
 END  
  SELECT * FROM @Usuarios u  
END