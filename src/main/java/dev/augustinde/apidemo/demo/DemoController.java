package dev.augustinde.apidemo.demo;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/demo")
public class DemoController {

    private final DemoRepository demoRepository;

    public DemoController(DemoRepository demoRepository) {
        this.demoRepository = demoRepository;
    }

    /** Renvoie toutes les lignes de la table demo. */
    @GetMapping
    public List<DemoItem> list() {
        return demoRepository.findAll();
    }
}
