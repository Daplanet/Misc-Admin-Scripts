<?php
        $DomainName = "example.com";
        $VIP = "12.34.56.78";

        HttpRequest::methodRegister('PURGE');
        $request = new HttpRequest("http://$VIP/default.asp", HttpRequest::METH_PURGE);
        $request->setHeaders(array('Host' => "$DomainName"));
        try {
                $request->send();
                var_dump($request->getResponseCode());
                if ($request->getResponseCode() == 200) {
                        echo "Success!!";
                }
        } catch (HttpException $exception) {
                echo $exception;
        }
?>
